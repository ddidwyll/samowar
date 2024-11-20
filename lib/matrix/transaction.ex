defmodule Matrix.Transaction do
  use Matrix, adapter: :transaction

  def new_event(event) do
    De.bug_full(event, :new_event)
  end
end
