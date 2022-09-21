defmodule PlasticCard.NumberTest do
  @moduledoc false

  use ExUnit.Case
  alias PlasticCard.{Number, Type}

  doctest Number

  describe "from_string/2" do
    test "valid numbers" do
      card_number = "4024007110750378"

      {:ok, type} =
        Type.card_types()
        |> Type.card_type(card_number)

      assert {:ok, %Number{number: ^card_number}} = Number.from_string(type, card_number)
    end

    test "invalid card test number" do
      card_number = "0123 4567 8901 2345"

      assert {:error, :test_number} =
               %Type{test_numbers: ["0123456789012345"]}
               |> Number.from_string(card_number)
    end
  end

  describe "bin/1" do
    test "retrieve bin from card number" do
      card_number = "4024007110750378"

      {:ok, type} =
        Type.card_types()
        |> Type.card_type(card_number)

      assert {:ok, %Number{number: ^card_number} = number} = Number.from_string(type, card_number)

      assert "402400" == Number.bin(number)
    end
  end

  describe "last_4_digits/1" do
    test "retrieve last 4 digits from card number" do
      card_number = "4024007110750378"

      {:ok, type} =
        Type.card_types()
        |> Type.card_type(card_number)

      assert {:ok, %Number{number: ^card_number} = number} = Number.from_string(type, card_number)

      assert "0378" == Number.last_4_digits(number)
    end
  end
end
