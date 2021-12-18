defmodule Homework.Util.Paginator do
  import Ecto.Query

  alias Homework.Repo

  @doc """
    Use the provided page/page_size params to return a slice of the total results.
  """
  def page(query, %{page: page, page_size: page_size}) do
    paged_query = query
    |> limit(^page_size)
    |> offset((^page - 1) * ^page_size)
    |> Repo.all()

    count = Repo.one(from(x in subquery(query), select: count("*")))

    {:ok, paged_query, %{page: page, page_size: page_size, total_rows: count}}

  end

  @doc """
    Wrap the result set up with the pagination info. For now it just returns the
    total number of rows, but it takes in a map with enough info to populate
    other info (prev/next page info, etc) in the future.
  """
  def finalize(results, page_info) do
    %{
      entries: results,
      total_rows: page_info.total_rows
    }

  end
end
