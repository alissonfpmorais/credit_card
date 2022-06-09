defmodule PlasticCard.SecurityCode do
  @moduledoc false

  alias PlasticCard.{SecurityCode, Type}

  defstruct [:security_code]

  @type t() :: %__MODULE__{
          security_code: String.t()
        }

  @spec from_string(Type.t(), String.t()) :: {:ok, SecurityCode.t()} | {:error, term()}
  def from_string(%Type{security_code: %{size: size}}, security_code) do
    pattern = ~r/^\d{#{size}}$/

    case String.match?(security_code, pattern) do
      true -> {:ok, %SecurityCode{security_code: security_code}}
      false -> {:error, :invalid_security_code}
    end
  end
end
