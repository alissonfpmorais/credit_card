defmodule PlasticCard do
  @moduledoc false

  alias PlasticCard.{ExpirationDate, Holder, Number, SecurityCode, Type}

  defstruct [:number, :holder_name, :expiration_date, :security_code, :type]

  @type t() :: %__MODULE__{
          number: Number.t(),
          holder_name: Holder.t(),
          expiration_date: ExpirationDate.t(),
          security_code: SecurityCode.t(),
          type: Type.t()
        }

  @type parse_options() :: [
          test_numbers_allowed: boolean()
        ]

  @parse_opts [
    test_numbers_allowed: false
  ]

  @spec from_raw(String.t(), String.t(), String.t(), String.t(), Keyword.t()) ::
          {:ok, PlasticCard.t()} | {:error, term()}
  def from_raw(card_number, full_name, expiration_date, security_code, opts \\ [])
      when is_binary(card_number) and
             is_binary(full_name) and
             is_binary(expiration_date) and
             is_binary(security_code) do
    opts = Keyword.merge(@parse_opts, opts)

    with {:ok, type} <- Type.card_type(Type.card_types(), card_number),
         {:ok, card_number} <- Number.from_string(type, card_number, opts),
         {:ok, holder_name} <- Holder.from_string(full_name),
         {:ok, expiration_date} <- ExpirationDate.from_string(expiration_date),
         {:ok, security_code} <- SecurityCode.from_string(type, security_code) do
      {:ok,
       %__MODULE__{
         number: card_number,
         holder_name: holder_name,
         expiration_date: expiration_date,
         security_code: security_code,
         type: type
       }}
    end
  end

  @spec card_number(PlasticCard.t()) :: String.t()
  def card_number(%PlasticCard{number: %Number{number: number}}), do: number

  @spec bin(PlasticCard.t()) :: String.t()
  def bin(%PlasticCard{number: number}), do: Number.bin(number)

  @spec last_4_digits(PlasticCard.t()) :: String.t()
  def last_4_digits(%PlasticCard{number: number}), do: Number.last_4_digits(number)

  @spec holder_name(PlasticCard.t()) :: String.t()
  def holder_name(%PlasticCard{holder_name: %Holder{holder_name: holder_name}}),
    do: holder_name

  @spec holder_first_name(PlasticCard.t()) :: String.t()
  def holder_first_name(%PlasticCard{holder_name: %Holder{first_name: first_name}}),
    do: first_name

  @spec holder_last_name(PlasticCard.t()) :: String.t()
  def holder_last_name(%PlasticCard{holder_name: %Holder{last_name: last_name}}), do: last_name

  @spec expiration_date(PlasticCard.t()) :: String.t()
  def expiration_date(%PlasticCard{expiration_date: %ExpirationDate{normalized: normalized}}),
    do: normalized

  @spec expiration_month(PlasticCard.t()) :: String.t()
  def expiration_month(%PlasticCard{expiration_date: %ExpirationDate{month: month}}),
    do: month

  @spec expiration_year(PlasticCard.t()) :: String.t()
  def expiration_year(%PlasticCard{expiration_date: %ExpirationDate{year: year}}),
    do: year

  @spec security_code(PlasticCard.t()) :: String.t()
  def security_code(%PlasticCard{security_code: %SecurityCode{security_code: security_code}}),
    do: security_code

  @spec type(PlasticCard.t()) :: Type.t()
  def type(%PlasticCard{type: type}), do: type
end
