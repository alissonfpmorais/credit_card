defmodule PlasticCard.Utils do
  @moduledoc false

  def normalize_text(text) do
    text
    |> String.split("")
    |> Enum.map_join("", &String.trim/1)
  end
end
