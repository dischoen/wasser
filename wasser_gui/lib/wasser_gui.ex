defmodule WasserGui do
  @moduledoc """
  WasserGui keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """


  def channelmap do
    %{westen: 5,
      osten:  6,
      rasen:  13,
      beete:  16}
  end

  def channellist do
    Enum.map channelmap(), fn {k, _v} -> k end
  end

end
