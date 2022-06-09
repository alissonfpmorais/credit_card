defmodule PlasticCard.HolderTest do
  @moduledoc false

  use ExUnit.Case
  alias PlasticCard.Holder

  doctest Holder

  describe "from_string/1" do
    test "formatted name" do
      full_name = "HARRY JAMES POTTER"

      assert {:ok,
              %Holder{
                first_name: "HARRY",
                last_name: "POTTER",
                holder_name: "HARRY JAMES POTTER"
              }} = Holder.from_string(full_name)
    end

    test "blank spaces should be normalized" do
      full_name = "  WILLIAM  BYERS    "

      assert {:ok,
              %Holder{
                first_name: "WILLIAM",
                last_name: "BYERS",
                holder_name: "WILLIAM BYERS"
              }} = Holder.from_string(full_name)
    end

    test "different cases should be normalized" do
      full_name = "Emmett Brown"

      assert {:ok,
              %Holder{
                first_name: "EMMETT",
                last_name: "BROWN",
                holder_name: "EMMETT BROWN"
              }} = Holder.from_string(full_name)
    end

    test "single name should raise error" do
      full_name = "GANDALF"
      assert {:error, :invalid_length} = Holder.from_string(full_name)
    end
  end

  describe "from_first_name_last_name/2" do
    test "unformatted name" do
      first_name = "Max"
      last_name = "Rockatansky"

      assert {:ok,
              %Holder{
                first_name: "MAX",
                last_name: "ROCKATANSKY",
                holder_name: "MAX ROCKATANSKY"
              }} = Holder.from_first_name_last_name(first_name, last_name)
    end
  end
end
