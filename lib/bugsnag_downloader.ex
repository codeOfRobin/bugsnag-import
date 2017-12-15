defmodule BugsnagDownloader do
  @moduledoc """
  Documentation for BugsnagDownloader.
  """

  @doc """
  Hello world.

  ## Examples

      iex> BugsnagDownloader.hello
      :world

  """
  def hello do
    :world
  end
   def gen_headers(token) do
    ["Authorization": "token #{token}",
    "X-Version": 2]
  end

  def get_project(%BugsnagDownloader.Request{url: url, token: token} = request) do
    headers = gen_headers(token)
    response = HTTPoison.get!(url, headers)
    %BugsnagDownloader.Request{ request | url: Poison.decode!(response.body)["errors_url"] } 
  end

  def get_open_errors(%BugsnagDownloader.Request{url: url, token: token} = request) do
    response = HTTPoison.get!(url, gen_headers(token))
    is_open? = fn(error) -> error["status"] == "open" end
    Enum.filter(Poison.decode!(response.body), is_open?) 
  end

  def get_events(%BugsnagDownloader.Request{url: url, token: token} = request) do
    response = HTTPoison.get!(url, gen_headers(token))
    events = Poison.decode!(response.body)
    length(events)
  end

  def main(request) do
    open_errors = request
      |> get_project
      |> get_open_errors
      |> Enum.map(fn(error) -> error["url"] <> "/events" end )
  end
end

defmodule Parallel do
  @doc """
      iex> Parallel.map([1,2,3], &(&1*2))
      [2,4,6]
  """
  def map(collection, function) do
    collection
    |> Enum.map(&Task.async(fn -> function.(&1) end))
    |> Enum.map(&Task.await(&1))
  end
end

