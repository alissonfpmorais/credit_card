defmodule CreditCardTest do
  @moduledoc false

  use ExUnit.Case
  doctest CreditCard

  describe "from_raw/5" do
    test "valid input should work successfully" do
      card_number = "4024007110750378"
      full_name = "Steve Rogers"
      expiration_date = "01/30"
      security_code = "123"

      assert {:ok, %CreditCard{}} =
               CreditCard.from_raw(card_number, full_name, expiration_date, security_code)
    end
  end
end
