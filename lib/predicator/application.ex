defmodule Predicator.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Supervisor.start_link([], [strategy: :one_for_one, name: Predicator.Supervisor])
  end
end
