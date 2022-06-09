defmodule CreditCard.ExpirationDateTest do
  @moduledoc false

  use ExUnit.Case
  alias CreditCard.ExpirationDate

  doctest ExpirationDate

  describe "from_month_and_year/2" do
    test "normalized date should stay the same" do
      month = "01"
      year = "30"

      assert {:ok, %ExpirationDate{normalized: "01/30"}} =
               ExpirationDate.from_month_and_year(month, year)
    end

    test "month as number should be normalized" do
      month = 1
      year = "30"

      assert {:ok, %ExpirationDate{normalized: "01/30"}} =
               ExpirationDate.from_month_and_year(month, year)
    end

    test "year as number should be normalized" do
      month = "01"
      year = 30

      assert {:ok, %ExpirationDate{normalized: "01/30"}} =
               ExpirationDate.from_month_and_year(month, year)
    end

    test "full year should be normalized" do
      month = "01"
      year = "2030"

      assert {:ok, %ExpirationDate{normalized: "01/30"}} =
               ExpirationDate.from_month_and_year(month, year)
    end

    test "blank spaces should be normalized" do
      month = " 01"
      year = "30 "

      assert {:ok, %ExpirationDate{normalized: "01/30"}} =
               ExpirationDate.from_month_and_year(month, year)
    end

    test "all 'errors' should be normalized" do
      month = "  1"
      year = 2030

      assert {:ok, %ExpirationDate{normalized: "01/30"}} =
               ExpirationDate.from_month_and_year(month, year)
    end

    test "invalid month should raise error" do
      month = 30
      year = 30
      assert {:error, :invalid_month} = ExpirationDate.from_month_and_year(month, year)
    end

    test "invalid year should raise error" do
      month = "01"
      year = 1830
      assert {:error, :invalid_year} = ExpirationDate.from_month_and_year(month, year)
    end
  end

  describe "from_string/1" do
    test "normalized date should stay the same" do
      expiration_date = "01/30"

      assert {:ok, %ExpirationDate{normalized: "01/30"}} =
               ExpirationDate.from_string(expiration_date)
    end

    test "dashed date should be normalized" do
      expiration_date = "01-30"

      assert {:ok, %ExpirationDate{normalized: "01/30"}} =
               ExpirationDate.from_string(expiration_date)
    end

    test "non-leading zero should be normalized" do
      expiration_date = "1/30"

      assert {:ok, %ExpirationDate{normalized: "01/30"}} =
               ExpirationDate.from_string(expiration_date)
    end

    test "blank spaces should be normalized" do
      expiration_date = "01 / 30 "

      assert {:ok, %ExpirationDate{normalized: "01/30"}} =
               ExpirationDate.from_string(expiration_date)
    end

    test "full year should be normalized" do
      expiration_date = "01/2030"

      assert {:ok, %ExpirationDate{normalized: "01/30"}} =
               ExpirationDate.from_string(expiration_date)
    end

    test "all 'errors' should be normalized" do
      expiration_date = " 1 - 2030 "

      assert {:ok, %ExpirationDate{normalized: "01/30"}} =
               ExpirationDate.from_string(expiration_date)
    end

    test "invalid month should raise error" do
      expiration_date = "30/30"
      assert {:error, :invalid_month} = ExpirationDate.from_string(expiration_date)
    end

    test "invalid year should raise error" do
      expiration_date = "01/1830"
      assert {:error, :invalid_year} = ExpirationDate.from_string(expiration_date)
    end
  end

  describe "from_date/1" do
    test "Date should be successfully parsed into ExpirationDate" do
      assert {:ok, %ExpirationDate{normalized: "01/30"}} =
               Date.new!(2030, 1, 1)
               |> ExpirationDate.from_date()
    end
  end

  describe "to_date/1" do
    test "ExpirationDate should be successfully parsed into Date" do
      assert {:ok, date} = Date.new(2030, 1, 1)
      assert {:ok, expiration_date} = ExpirationDate.from_date(date)
      assert {:ok, parsed_date} = ExpirationDate.to_date(expiration_date)
      assert ~D[2030-01-31] == parsed_date
    end
  end

  describe "expired?/1" do
    test "future expiration date should return success" do
      {:ok, expiration_date} = ExpirationDate.from_string("01/30")
      assert {:ok, false} = ExpirationDate.expired?(expiration_date)
    end

    test "current month/year expiration date should return success" do
      [year, month, _day] =
        Date.utc_today()
        |> Date.to_iso8601()
        |> String.split("-")

      {:ok, expiration_date} = ExpirationDate.from_string("#{month}/#{year}")

      assert {:ok, false} = ExpirationDate.expired?(expiration_date)
    end

    test "past expiration date should fail" do
      {:ok, expiration_date} = ExpirationDate.from_string("01/20")
      assert {:ok, true} = ExpirationDate.expired?(expiration_date)
    end
  end
end
