defmodule WasserFirmware.WasserSrv do
  use GenServer

  require Logger
  import Ecto.Query

  @on  0
  @off 1

  def start_link(args) do
    # you may want to register your server with `name: __MODULE__`
    # as a third argument to `start_link`
    GenServer.start_link(__MODULE__, args, [name: args.name])
  end

  @impl true
  def init(args) do
    {:ok, gpio} = Circuits.GPIO.open(args.pin, :output)
    switch(gpio, @off)
    jobs = get_jobs(args.name)
    PubSub.subscribe self(), args.name
    Logger.info init: args, msg: "all set up"
    {:ok, %{valve: args.name, gpio: gpio, jobs: jobs}}
  end

  def on(valve) do
    GenServer.call(valve, :on)
  end
  def off(valve) do
    GenServer.call(valve, :off)
  end
  def state(valve) do
    GenServer.call(valve, :state)
  end

  def jobs(valve) do
    GenServer.call(valve, :jobs)
  end
  
  @impl true
  def handle_call(:jobs, _from, state) do
    ret = Enum.map state.jobs, fn job ->
      job = Map.update job, :time_to_t0,
        Time.from_seconds_after_midnight(:timers.read_timer(job.ref0)),
        fn x -> x end
      Map.update job, :time_to_t1,
        Time.from_seconds_after_midnight(:timers.read_timer(job.ref1)),
        fn x -> x end
    end
    {:reply, ret, state}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, read(state.gpio), state}
  end


  @impl true
  def handle_call(:on, _from, state) do
    {:reply, switch(state.gpio, @on), state}
  end

  @impl true
  def handle_call(:off, _from, state) do
    {:reply, switch(state.gpio, @off), state}
  end

  # called by the timer
  # set the timer for the next occurence tomorrow
  @impl true
  def handle_info({:timeout, _Ref, {:on, t_start, id}}, state) do
    Logger.info action: "Starting job", valve: state.valve
    ref = :timers.set_timer_plus24(self(), t_start, :off)
    jobs = Enum.map(state.jobs,
      fn j ->
        if j.id == id do  
          %{j | ref0: ref}
        else
          j
        end
      end)
    switch(state.gpio, @on)
    {:noreply, %{state | jobs: jobs}}
  end

  @impl true
  def handle_info({:timeout, _Ref, {:off, t_stop, id}}, state) do
    Logger.info action: "Ending job", valve: state.valve
    ref = :timers.set_timer_plus24(self(), t_stop, :off)
    jobs = Enum.map(state.jobs,
      fn j ->
        if j.id == id do  
          %{j | ref1: ref}
        else
          j
        end
      end)
    switch(state.gpio, @off)
    {:noreply, %{state | jobs: jobs}}
  end
  
  @impl true
  def handle_info(:reload_db, state) do
    Logger.info action: "Job definition changed, reloading", valve: state.valve
    clear_timers(state.jobs)
    jobs = get_jobs(state.valve)
    {:noreply, %{state | jobs: jobs}}
  end
  

  defp switch(gpio, value) do
    Circuits.GPIO.write(gpio, value)
  end

  defp read(gpio) do
    case Circuits.GPIO.read(gpio) do
      @off -> "off"
      @on  -> "on"
    end
  end


  defp clear_timers(jobs) do
    Enum.each(jobs, fn job -> :timers.clear_timers(job.ref0, job.ref1) end)
  end
  
  defp get_jobs(valve) do
    jobs = WasserGui.Repo.all(from u in WasserGui.JobDefs.Job, where: u.valve == ^valve)
    Logger.info jobs: jobs, label: "jobs"
    jobs = Enum.map jobs, fn job ->
      Logger.info duration: job.duration, on: job.on
      {t_start, t_stop} = :timers.jobdef_to_monotime(
        {
          job.on.hour,
          job.on.minute,
          job.on.second},
        {
          job.duration.hour,
          job.duration.minute,
          job.duration.second})
      {ref0, ref1} = :timers.start_timers(
        self(),
        {t_start, t_stop},
        {{:on, t_start, job.id}, {:off, t_stop, job.id}})
      
      job = Map.update job, :ref0, ref0, fn x -> x end
      job = Map.update job, :ref1, ref1, fn x -> x end
      job = Map.take job, [:id, :on, :duration, :ref0, :ref1, :valve]

      Logger.info times: {t_start, t_stop},
        label: "timers",
        t0: :timers.read_timer(ref0),
        t1: :timers.read_timer(ref1)
      job
    end
    jobs
  end
end
