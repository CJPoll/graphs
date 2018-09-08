defmodule Stack do
  defstruct list: []

  @opaque t :: %__MODULE__{}
  @opaque t(subtype) :: %__MODULE__{list: [subtype]}
  @typep subtype :: term

  @spec new() :: t
  def new() do
    %__MODULE__{}
  end

  @spec new(Enumerable.t(subtype)) :: t(subtype)
  def new(enumerable) do
    list = Enum.reverse(enumerable)
    %__MODULE__{list: list}
  end

  @spec push(t(subtype), subtype) :: t(subtype)
  def push(%__MODULE__{list: list}, element) do
    %__MODULE__{list: [element | list]}
  end

  @spec peek(t(subtype)) :: subtype | :empty
  def(peek(%__MODULE__{list: [e | _]}), do: e)
  def peek(%__MODULE__{list: []}), do: :empty
end
