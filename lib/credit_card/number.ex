defmodule CreditCard.Number do
  @moduledoc false

  alias CreditCard.{Number, Type, Utils}

  defstruct [:number]

  @type t() :: %__MODULE__{
          number: String.t()
        }

  @type parse_options() :: [
          test_numbers_allowed: boolean()
        ]

  @parse_opts [
    test_numbers_allowed: false
  ]

  @spec from_string(Type.t(), String.t(), Keyword.t()) :: {:ok, Number.t()} | {:error, term()}
  def from_string(%Type{} = type, card_number, opts \\ [])
      when is_binary(card_number) and is_list(opts) do
    opts = Keyword.merge(@parse_opts, opts)
    test_numbers_allowed = opts[:test_numbers_allowed]

    with card_number <- Utils.normalize_text(card_number),
         {:ok, card_number} <- test_number?(type, test_numbers_allowed, card_number),
         {:ok, card_number} <- valid_luhn?(card_number) do
      {:ok, %__MODULE__{number: card_number}}
    end
  end

  defp valid_luhn?(card_number) do
    case Luhn.valid?(card_number) do
      true -> {:ok, card_number}
      false -> {:error, :invalid_number}
    end
  end

  defp test_number?(%Type{test_numbers: test_numbers}, test_number_allowed, card_number) do
    is_test_number = Enum.any?(test_numbers, fn test_number -> test_number == card_number end)

    case {test_number_allowed, is_test_number} do
      {false, true} -> {:error, :test_number}
      _ -> {:ok, card_number}
    end
  end
end
