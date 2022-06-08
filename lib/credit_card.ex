defmodule CreditCard do
  @moduledoc false

  @type validation_number_options() :: [
          allowed_card_types: nonempty_list(),
          test_numbers_are_valid: boolean()
        ]

  @card_types [
    visa: ~r/^4[0-9]{12}(?:[0-9]{3})?$/,
    master_card: ~r/^5[1-5][0-9]{14}$/,
    maestro:
      ~r/(^6759[0-9]{2}([0-9]{10})$)|(^6759[0-9]{2}([0-9]{12})$)|(^6759[0-9]{2}([0-9]{13})$)/,
    diners_club: ~r/^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
    amex: ~r/^3[47][0-9]{13}$/,
    discover: ~r/^6(?:011|5[0-9]{2})[0-9]{12}$/,
    jcb: ~r/^(?:2131|1800|35\d{3})\d{11}$/,
    unionpay: ~r/^62[0-5]\d{13,16}$/
  ]

  @test_numbers [
                  amex: ~w(378282246310005 371449635398431 378734493671000),
                  diners_club: ~w(30569309025904 38520000023237),
                  discover: ~w(6011000990139424 6011111111111117),
                  master_card: ~w(5555555555554444 5105105105105100),
                  visa:
                    ~w(4111111111111111 4012888888881881 4222222222222 4005519200000004 4009348888881881 4012000033330026 4012000077777777 4217651111111119 4500600000000061 4000111111111115 ),
                  jcb: ~w(3530111333300000 3566002020360505),
                  unionpay: ~w(6212341111111111)
                ]
                |> Keyword.values()
                |> List.flatten()

  @opts [
    allowed_card_types: Keyword.keys(@card_types),
    test_numbers: @test_numbers,
    test_numbers_are_valid: false
  ]

  @spec valid_number?(String.t(), validation_number_options()) :: boolean()
  def valid_number?(card_number, opts \\ []) when is_binary(card_number) and is_list(opts) do
    opts = Keyword.merge(@opts, opts)
    card_number = normalize_text(card_number)

    {
      opts[:test_numbers_are_valid],
      test_number?(opts[:test_numbers], card_number),
      Luhn.valid?(card_number)
    }
    |> case do
      {false, false, true} -> true
      {true, false, true} -> true
      {true, true, _} -> true
      _ -> false
    end
  end

  @spec normalize_date(String.t() | pos_integer(), String.t() | pos_integer()) ::
          {:ok, String.t()} | {:error, term()}
  def normalize_date(month, year)

  def normalize_date(month, year) when is_number(month) and is_number(year),
    do: normalize_date(to_string(month), to_string(year))

  def normalize_date(month, year) when is_number(month) and is_binary(year),
    do: normalize_date(to_string(month), year)

  def normalize_date(month, year) when is_binary(month) and is_number(year),
    do: normalize_date(month, to_string(year))

  def normalize_date(month, year) when is_binary(month) and is_binary(year) do
    with {:ok, month} <- normalize_month(month),
         {:ok, year} <- normalize_year(year) do
      {:ok, "#{month}/#{year}"}
    end
  end

  @spec normalize_date(String.t()) :: {:ok, String.t()} | {:error, term()}
  def normalize_date(expiration_date) when is_binary(expiration_date) do
    pattern = ~r/(\/)|(\-)/
    [month, year] = String.split(expiration_date, pattern, trim: true)

    normalize_date(month, year)
  end

  @spec month(String.t()) :: {:ok, String.t()} | {:error, term()}
  def month(expiration_date) when is_binary(expiration_date) do
    with {:ok, date} <- normalize_date(expiration_date) do
      month_from_normalized(date)
    end
  end

  @spec year(String.t()) :: {:ok, String.t()} | {:error, term()}
  def year(expiration_date) when is_binary(expiration_date) do
    with {:ok, date} <- normalize_date(expiration_date) do
      year_from_normalized(date)
    end
  end

  @spec full_year(String.t()) :: {:ok, String.t()} | {:error, term()}
  def full_year(expiration_date) when is_binary(expiration_date) do
    with {:ok, date} <- normalize_date(expiration_date) do
      full_year_from_normalized(date)
    end
  end

  @spec expired?(String.t()) :: {:ok, boolean()} | {:error, term()}
  def expired?(expiration_date) when is_binary(expiration_date) do
    with {:ok, date} <- normalize_date(expiration_date),
         {:ok, month} <- month_from_normalized(date),
         month <- String.to_integer(month),
         {:ok, full_year} <- full_year_from_normalized(date),
         full_year <- String.to_integer(full_year),
         today <- Date.utc_today(),
         last_day <- Date.days_in_month(today),
         {:ok, expiration_date} <- Date.new(full_year, month, last_day) do
      case Date.compare(expiration_date, today) do
        :lt -> {:ok, true}
        _ -> {:ok, false}
      end
    end
  end

  @spec expired?(String.t() | pos_integer(), String.t() | pos_integer()) ::
          {:ok, boolean()} | {:error, term()}
  def expired?(month, year)

  def expired?(month, year) when is_number(month) and is_number(year),
    do: expired?(to_string(month), to_string(year))

  def expired?(month, year) when is_number(month) and is_binary(year),
    do: expired?(to_string(month), year)

  def expired?(month, year) when is_binary(month) and is_number(year),
    do: expired?(month, to_string(year))

  def expired?(month, year) when is_binary(month) and is_binary(year),
    do: expired?("#{month}/#{year}")

  @spec(brand(String.t()) :: {:ok, atom()}, {:error, term()})
  def brand(card_number, opts \\ []) when is_binary(card_number) do
    opts = Keyword.merge([test_numbers_are_valid: true], opts)
    card_number = normalize_text(card_number)

    with true <- valid_number?(card_number, opts),
         brand when not is_nil(brand) <- recover_brand(card_number) do
      {:ok, brand}
    else
      false ->
        {:error, :invalid_number}

      nil ->
        {:error, :unknown_brand}
    end
  end

  defp normalize_text(text) do
    text
    |> String.split("")
    |> Enum.map_join("", &String.trim/1)
  end

  defp test_number?(test_numbers, card_number) do
    Enum.any?(test_numbers, fn number -> number == card_number end)
  end

  defp normalize_month(month) do
    right_month_pattern = ~r/^(0[1-9])|(1[0-2])$/
    non_leading_zero_pattern = ~r/^[1-9]$/
    month = normalize_text(month)

    cond do
      String.match?(month, right_month_pattern) -> {:ok, month}
      String.match?(month, non_leading_zero_pattern) -> {:ok, "0#{month}"}
      true -> {:error, :invalid_month}
    end
  end

  defp normalize_year(year) do
    right_year_pattern = ~r/^[0-9][0-9]$/
    non_leading_zero_pattern = ~r/^[0-9]$/
    full_year_pattern = ~r/^(19[0-9][0-9])|(20[0-9][0-9])$/
    year = normalize_text(year)

    cond do
      String.match?(year, right_year_pattern) -> {:ok, year}
      String.match?(year, non_leading_zero_pattern) -> {:ok, "0#{year}"}
      String.match?(year, full_year_pattern) -> {:ok, String.slice(year, 2..-1)}
      true -> {:error, :invalid_year}
    end
  end

  defp month_from_normalized(date) do
    [month, _year] = String.split(date, "/")
    {:ok, month}
  end

  defp year_from_normalized(date) do
    [_month, year] = String.split(date, "/")
    {:ok, year}
  end

  defp full_year_from_normalized(date) do
    with {:ok, year} <- year_from_normalized(date) do
      century =
        Date.utc_today()
        |> Date.year_of_era()
        |> Tuple.to_list()
        |> Enum.at(0)
        |> to_string()
        |> String.slice(0..1)

      {:ok, "#{century}#{year}"}
    end
  end

  defp recover_brand(card_number) do
    @card_types
    |> Enum.filter(fn {_brand, pattern} -> String.match?(card_number, pattern) end)
    |> Enum.map(fn {brand, _pattern} -> brand end)
    |> Enum.at(0)
  end
end
