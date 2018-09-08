defmodule DirectedGraph do
  defstruct vertices: MapSet.new(), edges: %{}

  defmodule MissingNodeException do
    defexception [:message]
  end

  def new() do
    %__MODULE__{}
  end

  def children_of(%__MODULE__{edges: edges} = graph, vertex) do
    unless node?(graph, vertex) do
      raise MissingNodeException, "#{inspect(vertex)} not found in graph"
    end

    Map.get(edges, vertex, MapSet.new())
  end

  def node?(%__MODULE__{vertices: vertices}, vertex) do
    vertex in vertices
  end

  def with_edge(%__MODULE__{} = graph, left, right) do
    cond do
      not node?(graph, left) ->
        raise MissingNodeException, "#{inspect(left)} not found in graph"

      not node?(graph, right) ->
        raise MissingNodeException, "#{inspect(right)} not found in graph"

      true ->
        add_edge(graph, left, right)
    end
  end

  def with_node(%__MODULE__{vertices: vertices} = graph, vertex) do
    vertices = MapSet.put(vertices, vertex)

    %__MODULE__{graph | vertices: vertices}
  end

  defp add_edge(%__MODULE__{edges: edges} = graph, left, right) do
    edges = Map.update(edges, left, MapSet.new([right]), &MapSet.put(&1, right))
    %__MODULE__{graph | edges: edges}
  end
end

defimpl Enumerable, for: DirectedGraph do
  @graph DirectedGraph

  defmodule Accumulator do
    @graph DirectedGraph
    defstruct [:acc, traversed: MapSet.new(), traversing: Stack.new()]

    def new(acc) do
      %__MODULE__{acc: acc}
    end

    def all_traversed?(%__MODULE__{traversed: traversed}, %@graph{} = graph) do
      traversed?(traversed, graph.vertices)
    end

    def traversed?(%__MODULE__{traversed: traversed}, vertices) do
      MapSet.subset?(vertices, traversed)
    end

    def remaining_vertices(%__MODULE__{traversed: traversed}, %@graph{} = graph) do
      MapSet.difference(graph.vertices, traversed)
    end

    def add_traversed(%__MODULE__{} = a, vertex, acc) do
      traversed = MapSet.put(a.traversed, vertex)
      %__MODULE__{a | traversed: traversed, acc: acc}
    end
  end

  def count(%@graph{vertices: vertices}) do
    MapSet.size(vertices)
  end

  def member?(%@graph{vertices: vertices}, vertex) do
    MapSet.member?(vertices, vertex)
  end

  def slice(%@graph{vertices: vertices}) do
    {:ok, MapSet.size(vertices), &Enumerable.List.slice(MapSet.to_list(vertices), &1, &2)}
  end

  def reduce(_graph, {:halt, %Accumulator{} = acc}, _fun) do
    {:halted, acc.acc}
  end

  def reduce(graph, {:suspend, %Accumulator{} = acc}, fun) do
    {:suspended, acc, &reduce(graph, &1, fun)}
  end

  def reduce(graph, {:cont, %Accumulator{} = acc}, fun) do
    if(Accumulator.all_traversed?(acc, graph)) do
      {:done, acc.acc}
    else
      acc |> Accumulator.remaining_vertices() |> Enum.random() |> reduce(graph, acc, fun)
    end
  end

  def reduce(graph, {event, acc}, fun) do
    reduce(graph, {event, Accumulator.new(acc)}, fun)
  end

  defp reduce(vertex, graph, %Accumulator{} = acc, fun) do
    acc = if(Accumulator.traversed?(@graph.children_of(vertex)))
  end
end
