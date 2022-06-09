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
end
