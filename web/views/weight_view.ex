defmodule ParkinsonsAndMe.WeightView do
  use ParkinsonsAndMe.Web, :view

  def render("weight.json", %{weight: weight}) do
    %{id: weight.id,
      quote_id: weight.quote_id,
      service_id: weight.service_id,
      weight: weight.weight}
  end

  def group_by_quote(raw_weights) do
    raw_weights
    |> Enum.sort_by(fn(x) -> x.quote.id end)
    |> Enum.chunk_by(fn(x) -> x.quote.body end)
    |> Enum.map(&sort_by_sid/1)
  end

  def sort_by_sid(services) do
    services
    |> Enum.sort_by(fn(x) -> x.service.id end)
  end

  def get_color(weight) do
    cond do
      weight >= 1
        -> "white bg-purple"
      weight >= 0.75
        -> "black bg-gold"
      weight >= 0.5
        -> "white bg-light-green"
      weight >= 0.25
        -> "white bg-light-blue"
      true
        -> "black"
    end
  end
end
