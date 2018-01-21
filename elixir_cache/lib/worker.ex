defmodule ElixirCache.Worker do
  use GenServer

  ## CLIENT API

  @name Cache

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: Cache])
  end

  def write(key, value) do
    GenServer.cast(@name, {:write, {key, value}})
  end

  def read(key) do
    GenServer.call(@name, {:read, key})
  end

  def delete(key) do
    GenServer.cast(@name, {:delete, key})
  end

  def clear do
    GenServer.cast(@name, :clear) 
  end

  def exist?(key) do
    GenServer.call(@name, {:exists? , key})
  end
  
  def stop do
    GenServer.cast(@name, :stop)
  end

  ## SERVER CALLBACKS

  def init(:ok) do
    {:ok, %{}}
  end

  def terminate(reason, cache) do
    IO.puts "Server terminated because of #{inspect reason}"
      inspect cache
    :ok
  end

  def handle_cast({:write, {key, value}}, cache) do
    new_cache = update_cache(cache, {key, value})
    {:noreply, new_cache}
  end

  def handle_cast({:delete, key}, cache) do
    new_cache = delete_key(cache, key)
    {:noreply, new_cache}
  end

  def handle_cast(:clear, cache) do
    {:noreply, %{}}
  end

  def handle_call({:read, key}, _from, cache) do
    value = Map.get(cache, key)
    {:reply, value, cache}
  end

  def handle_call({:exists?, key}, _from, cache) do
    exists? = key_exists(cache, key)
    {:reply, exists?, cache}
  end

  def handle_info(message, cache) do
    IO.puts "Received #{message}"
    {:noreply, cache}
  end

  ## HELPER FUNCTIONS

  defp update_cache(cache, {key, value}) do
    case Map.has_key?(cache, key) do
      true -> 
        Map.update!(cache, key, fn x -> value end)
      false ->
        Map.put_new(cache, key, value)
    end
  end

  defp key_exists(cache, key) do
    Map.has_key?(cache, key)
  end

  defp delete_key(cache, key) do
    case Map.has_key?(cache, key) do
      true -> 
        Map.delete(cache, key)
      false ->
        cache
    end
  end  
end