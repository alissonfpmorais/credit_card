defmodule CreditCard.ExpirationDate do
  @moduledoc false

  alias CreditCard.{ExpirationDate, Utils}

  defstruct [
    :month,
    :month_value,
    :year,
    :year_value,
    :full_year,
    :full_year_value,
    :normalized
  ]

  @type t() :: %__MODULE__{
          month: String.t(),
          month_value: pos_integer(),
          year: String.t(),
          year_value: pos_integer(),
          full_year: String.t(),
          full_year_value: pos_integer(),
          normalized: String.t()
        }

  @spec from_month_and_year(String.t() | pos_integer(), String.t() | pos_integer()) ::
          {:ok, ExpirationDate.t()} | {:error, term()}
  def from_month_and_year(month, year)

  def from_month_and_year(month, year) when is_number(month) and is_number(year),
    do: from_month_and_year(to_string(month), to_string(year))

  def from_month_and_year(month, year) when is_number(month) and is_binary(year),
    do: from_month_and_year(to_string(month), year)

  def from_month_and_year(month, year) when is_binary(month) and is_number(year),
    do: from_month_and_year(month, to_string(year))

  def from_month_and_year(month, year) when is_binary(month) and is_binary(year) do
    with {:ok, month} <- normalize_month(month),
         {:ok, year} <- normalize_year(year) do
      full_year = "#{year_prefix()}#{year}"

      {:ok,
       %__MODULE__{
         month: month,
         month_value: String.to_integer(month),
         year: year,
         year_value: String.to_integer(year),
         full_year: full_year,
         full_year_value: String.to_integer(full_year),
         normalized: "#{month}/#{year}"
       }}
    end
  end

  @spec from_string(String.t()) :: {:ok, ExpirationDate.t()} | {:error, term()}
  def from_string(expiration_date) when is_binary(expiration_date) do
    case String.split(expiration_date, ~r/(\/)|(\-)/, trim: true) do
      [month, year] -> from_month_and_year(month, year)
      _ -> {:error, :invalid_format}
    end
  end

  @spec from_date(Date.t()) :: {:ok, ExpirationDate.t()} | {:error, term()}
  def from_date(%Date{} = date) do
    date
    |> Date.to_iso8601()
    |> String.split("-")
    |> case do
      [year, month, _day] -> from_month_and_year(month, year)
      _ -> {:error, :invalid_date}
    end
  end

  @spec to_date(ExpirationDate.t()) :: {:ok, Date.t()} | {:error, term()}
  def to_date(%ExpirationDate{month_value: month, full_year_value: year}) do
    with {:ok, date} <- Date.new(year, month, 1) do
      {:ok, Date.end_of_month(date)}
    end
  end

  @spec expired?(ExpirationDate.t()) :: {:ok, boolean()} | {:error, term()}
  def expired?(%ExpirationDate{} = expiration_date) do
    with {:ok, date} <- to_date(expiration_date) do
      date
      |> Date.compare(Date.utc_today())
      |> case do
        :lt -> {:ok, true}
        _ -> {:ok, false}
      end
    end
  end

  defp normalize_year(year) do
    right_year_pattern = ~r/^[0-9][0-9]$/
    non_leading_zero_pattern = ~r/^[0-9]$/
    full_year_pattern = ~r/^(19[0-9][0-9])|(20[0-9][0-9])$/
    year = Utils.normalize_text(year)

    cond do
      String.match?(year, right_year_pattern) -> {:ok, year}
      String.match?(year, non_leading_zero_pattern) -> {:ok, "0#{year}"}
      String.match?(year, full_year_pattern) -> {:ok, String.slice(year, 2..-1)}
      true -> {:error, :invalid_year}
    end
  end

  defp normalize_month(month) do
    right_month_pattern = ~r/^(0[1-9])|(1[0-2])$/
    non_leading_zero_pattern = ~r/^[1-9]$/
    month = Utils.normalize_text(month)

    cond do
      String.match?(month, right_month_pattern) -> {:ok, month}
      String.match?(month, non_leading_zero_pattern) -> {:ok, "0#{month}"}
      true -> {:error, :invalid_month}
    end
  end

  defp year_prefix do
    Date.utc_today()
    |> Date.to_string()
    |> String.split("-")
    |> Enum.at(0)
    |> String.slice(0..1)
  end
end
