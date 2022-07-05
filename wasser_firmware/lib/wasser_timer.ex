defmodule WasserFirmware.WasserTimer do
  use GenServer

  require Logger
  # UTC+2
  @dst 2
  
  def start_link(_args) do
    # you may want to register your server with `name: __MODULE__`
    # as a third argument to `start_link`
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  @impl true
  def init(_args) do
    Process.send_after(self(), :re_read_db, 20_000)
    {:ok, []}
  end

  @impl true
  def handle_info(:timer, jobs) do
    now = Time.add(Time.utc_now, @dst*3600, :second)
    Logger.info now
    Enum.each(jobs, fn job ->
      check_job(job, now)
    end)

    start_timer(length(jobs))

    {:noreply, jobs}
  end

  @impl true
  def handle_info(:re_read_db, _jobs) do
    Logger.info "re-reading jobs"
    jobs = WasserGui.JobDefs.list_jobs
    start_timer(length(jobs))
    {:noreply, jobs}
  end

  defp start_timer(0) do
    Logger.info "no timer set up"
  end
  defp start_timer(_x) do
    Logger.info "setup timer"
    Process.send_after(self(), :timer, 60_000)
  end
  

  defp check_job(job, now) do
    Logger.info [job: job, label: "checking  job"]
    if job.on.hour   == now.hour and
    job.on.minute == now.minute do
      Task.start_link(fn -> start_job(job) end)
    end
  end

  defp start_job(job) do
    Logger.info [job: job, label: "starting job"]
    WasserFirmware.WasserSrv.on(String.to_atom(job.valve))
    Process.sleep(job.duration.minute*60_000 + job.duration.second*1_000)
    WasserFirmware.WasserSrv.off(String.to_atom(job.valve))
    Logger.info [job: job, label: "finished job"]
    :ok
  end
      

end
