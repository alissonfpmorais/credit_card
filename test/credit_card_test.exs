defmodule CreditCardTest do
  @moduledoc false

  use ExUnit.Case
  doctest CreditCard

  describe "valid_number?/1" do
    test "valid non test credit card number should return success" do
      test_number = "4111 1111 1111 1111"
      assert CreditCard.valid_number?(test_number) == false

      valid_number = "4024 0071 1075 0378"
      assert CreditCard.valid_number?(valid_number) == true
    end

    test "invalid credit card number should fail" do
      invalid_number = "0123 4567 8901 2345"
      assert CreditCard.valid_number?(invalid_number) == false
    end

    test "testing credit card number should fail" do
      test_number = "4111 1111 1111 1111"
      assert CreditCard.valid_number?(test_number, test_numbers_are_valid: true) == true
    end
  end

  describe "normalize_date/2" do
    test "normalized date should stay the same" do
      month = "01"
      year = "30"
      assert {:ok, "01/30"} = CreditCard.normalize_date(month, year)
    end

    test "month as number should be normalized" do
      month = 1
      year = "30"
      assert {:ok, "01/30"} = CreditCard.normalize_date(month, year)
    end

    test "year as number should be normalized" do
      month = "01"
      year = 30
      assert {:ok, "01/30"} = CreditCard.normalize_date(month, year)
    end

    test "full year should be normalized" do
      month = "01"
      year = "2030"
      assert {:ok, "01/30"} = CreditCard.normalize_date(month, year)
    end

    test "blank spaces should be normalized" do
      month = " 01"
      year = "30 "
      assert {:ok, "01/30"} = CreditCard.normalize_date(month, year)
    end

    test "all 'errors' should be normalized" do
      month = "  1"
      year = 2030
      assert {:ok, "01/30"} = CreditCard.normalize_date(month, year)
    end

    test "invalid month should raise error" do
      month = 30
      year = 30
      assert {:error, :invalid_month} = CreditCard.normalize_date(month, year)
    end

    test "invalid year should raise error" do
      month = "01"
      year = 1830
      assert {:error, :invalid_year} = CreditCard.normalize_date(month, year)
    end
  end

  describe "normalize_date/1" do
    test "normalized date should stay the same" do
      expiration_date = "01/30"
      assert {:ok, "01/30"} = CreditCard.normalize_date(expiration_date)
    end

    test "dashed date should be normalized" do
      expiration_date = "01-30"
      assert {:ok, "01/30"} = CreditCard.normalize_date(expiration_date)
    end

    test "non-leading zero should be normalized" do
      expiration_date = "1/30"
      assert {:ok, "01/30"} = CreditCard.normalize_date(expiration_date)
    end

    test "blank spaces should be normalized" do
      expiration_date = "01 / 30 "
      assert {:ok, "01/30"} = CreditCard.normalize_date(expiration_date)
    end

    test "full year should be normalized" do
      expiration_date = "01/2030"
      assert {:ok, "01/30"} = CreditCard.normalize_date(expiration_date)
    end

    test "all 'errors' should be normalized" do
      expiration_date = " 1 - 2030 "
      assert {:ok, "01/30"} = CreditCard.normalize_date(expiration_date)
    end

    test "invalid month should raise error" do
      expiration_date = "30/30"
      assert {:error, :invalid_month} = CreditCard.normalize_date(expiration_date)
    end

    test "invalid year should raise error" do
      expiration_date = "01/1830"
      assert {:error, :invalid_year} = CreditCard.normalize_date(expiration_date)
    end
  end

  describe "month/1" do
    test "retrieve month successfully from valid expiration date" do
      expiration_date = "01/30"
      assert {:ok, "01"} = CreditCard.month(expiration_date)
    end

    test "retrieve month from invalid expiration date should fail" do
      expiration_date = "30/01"
      assert {:error, :invalid_month} = CreditCard.month(expiration_date)
    end
  end

  describe "year/1" do
    test "retrieve year successfully from valid expiration date" do
      expiration_date = "01/30"
      assert {:ok, "30"} = CreditCard.year(expiration_date)
    end

    test "retrieve year from invalid expiration date should fail" do
      expiration_date = "01/1830"
      assert {:error, :invalid_year} = CreditCard.year(expiration_date)
    end
  end

  describe "full_year/1" do
    test "retrieve full year successfully from valid expiration date" do
      expiration_date = "01/30"
      assert {:ok, "2030"} = CreditCard.full_year(expiration_date)
    end

    test "retrieve full year from invalid expiration date should fail" do
      expiration_date = "01/1830"
      assert {:error, :invalid_year} = CreditCard.full_year(expiration_date)
    end
  end

  describe "expired?/1" do
    test "future expiration date should return success" do
      expiration_date = "01/30"
      assert {:ok, false} = CreditCard.expired?(expiration_date)
    end

    test "current month/year expiration date should return success" do
      [year, month, _day] =
        Date.utc_today()
        |> Date.to_iso8601()
        |> String.split("-")

      expiration_date = "#{month}/#{year}"

      assert {:ok, false} = CreditCard.expired?(expiration_date)
    end

    test "past expiration date should fail" do
      expiration_date = "01/20"
      assert {:ok, true} = CreditCard.expired?(expiration_date)
    end
  end

  describe "expired?/2" do
    test "future expiration date should return success" do
      month = "01"
      year = "30"
      assert {:ok, false} = CreditCard.expired?(month, year)
    end

    test "current month/year expiration date should return success" do
      [year, month, _day] =
        Date.utc_today()
        |> Date.to_iso8601()
        |> String.split("-")

      assert {:ok, false} = CreditCard.expired?(month, year)
    end

    test "past expiration date should fail" do
      month = "01"
      year = "20"
      assert {:ok, true} = CreditCard.expired?(month, year)
    end
  end

  describe "brand/1" do
    test "visa brand should return successful" do
      card_number = "4111111111111111"
      assert CreditCard.brand(card_number) == {:ok, :visa}
    end

    test "master card brand should return successful" do
      card_number = "5555555555554444"
      assert CreditCard.brand(card_number) == {:ok, :master_card}
    end

    test "diners club brand should return successful" do
      card_number = "30569309025904"
      assert CreditCard.brand(card_number) == {:ok, :diners_club}
    end

    test "amex brand should return successful" do
      card_number = "371449635398431"
      assert CreditCard.brand(card_number) == {:ok, :amex}
    end

    test "discover brand should return successful" do
      card_number = "6011000990139424"
      assert CreditCard.brand(card_number) == {:ok, :discover}
    end

    test "maestro brand should return successful" do
      card_number = "6759671431256542"
      assert CreditCard.brand(card_number) == {:ok, :maestro}
    end

    test "jcb brand should return successful" do
      card_number = "3530111333300000"
      assert CreditCard.brand(card_number) == {:ok, :jcb}
    end

    test "unionpay brand should return successful" do
      card_number = "6212341111111111"
      assert CreditCard.brand(card_number) == {:ok, :unionpay}
    end
  end
end
