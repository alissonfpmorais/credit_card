defmodule PlasticCard.Holder do
  @moduledoc false

  alias PlasticCard.Holder

  defstruct [:first_name, :last_name, :holder_name]

  @type t() :: %__MODULE__{
          first_name: String.t(),
          last_name: String.t(),
          holder_name: String.t()
        }

  @spec from_string(String.t()) :: {:ok, Holder.t()} | {:error, term()}
  def from_string(full_name) when is_binary(full_name) do
    names =
      full_name
      |> String.split(" ")
      |> Enum.filter(fn name -> name != "" end)
      |> Enum.map(&normalize_name/1)

    case Enum.count(names) do
      0 ->
        {:error, :invalid_length}

      1 ->
        {:error, :invalid_length}

      _ ->
        {:ok,
         %Holder{
           first_name: Enum.at(names, 0),
           last_name: Enum.at(names, -1),
           holder_name: Enum.join(names, " ")
         }}
    end
  end

  @spec from_first_name_last_name(String.t(), String.t()) ::
          {:ok, Holder.t()} | {:error, term()}
  def from_first_name_last_name(first_name, last_name)
      when is_binary(first_name) and is_binary(last_name) do
    from_string("#{first_name} #{last_name}")
  end

  defp normalize_name(name) do
    String.upcase(name)
  end
end
