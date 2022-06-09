defmodule PlasticCard.SecurityCodeTest do
  @moduledoc false

  use ExUnit.Case
  alias PlasticCard.{SecurityCode, Type}

  doctest SecurityCode

  describe "from_string/1" do
    setup do
      {:ok, type: %Type{security_code: %{size: 3}}}
    end

    test "valid security code", %{type: type} do
      security_code = "123"

      assert {:ok, %SecurityCode{security_code: "123"}} =
               SecurityCode.from_string(type, security_code)
    end

    test "invalid security code", %{type: type} do
      security_code = "1234"
      assert {:error, :invalid_security_code} = SecurityCode.from_string(type, security_code)
    end
  end
end
