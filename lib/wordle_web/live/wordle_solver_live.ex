defmodule WordleWeb.WordleSolverLive do
  use WordleWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       known_letters: "",
       excluded_letters: "",
       position_1: "",
       position_2: "",
       position_3: "",
       position_4: "",
       position_5: "",
       results: [],
       loading: false,
       error: nil
     )}
  end

  @impl true
  def handle_event("solve", %{"solver" => params}, socket) do
    known_letters = params["known_letters"] || ""
    excluded_letters = params["excluded_letters"] || ""

    positions =
      1..5
      |> Enum.reduce(%{}, fn pos, acc ->
        position_key = "position_#{pos}"
        letter = params[position_key] || ""

        if letter != "" do
          Map.put(acc, pos, letter)
        else
          acc
        end
      end)

    # Start loading state
    socket = assign(socket, loading: true, error: nil)

    try do
      results = Wordle.Solver.get_possible_words(known_letters, excluded_letters, positions)

      {:noreply,
       assign(socket,
         known_letters: known_letters,
         excluded_letters: excluded_letters,
         position_1: params["position_1"] || "",
         position_2: params["position_2"] || "",
         position_3: params["position_3"] || "",
         position_4: params["position_4"] || "",
         position_5: params["position_5"] || "",
         results: results,
         loading: false
       )}
    rescue
      e ->
        {:noreply,
         assign(socket,
           loading: false,
           error: "Error finding words: #{Exception.message(e)}"
         )}
    end
  end

  @impl true
  def handle_event("clear", _params, socket) do
    {:noreply,
     assign(socket,
       known_letters: "",
       excluded_letters: "",
       position_1: "",
       position_2: "",
       position_3: "",
       position_4: "",
       position_5: "",
       results: [],
       loading: false,
       error: nil
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-6">
      <div class="bg-white shadow-lg rounded-lg p-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Wordle Solver</h1>
        <p class="text-gray-600 mb-8">
          Enter what you know about the word for help with the solution.
        </p>

        <.form for={%{}} phx-submit="solve" class="space-y-6">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Known Letters -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Letters in the word
              </label>
              <input
                type="text"
                name="solver[known_letters]"
                value={@known_letters}
                placeholder="e.g., aer"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <p class="text-xs text-gray-500 mt-1">
                Letters you know are in the word (any position)
              </p>
            </div>

    <!-- Excluded Letters -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Letters NOT in the word
              </label>
              <input
                type="text"
                name="solver[excluded_letters]"
                value={@excluded_letters}
                placeholder="e.g., xyz"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <p class="text-xs text-gray-500 mt-1">
                Letters you know are NOT in the word
              </p>
            </div>
          </div>

    <!-- Position-specific letters -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-3">
              Known positions
            </label>
            <div class="grid grid-cols-5 gap-2">
              <div class="text-center">
                <label class="block text-xs text-gray-500 mb-1">1st</label>
                <input
                  type="text"
                  name="solver[position_1]"
                  value={@position_1}
                  maxlength="1"
                  class="w-full px-2 py-2 text-center border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div class="text-center">
                <label class="block text-xs text-gray-500 mb-1">2nd</label>
                <input
                  type="text"
                  name="solver[position_2]"
                  value={@position_2}
                  maxlength="1"
                  class="w-full px-2 py-2 text-center border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div class="text-center">
                <label class="block text-xs text-gray-500 mb-1">3rd</label>
                <input
                  type="text"
                  name="solver[position_3]"
                  value={@position_3}
                  maxlength="1"
                  class="w-full px-2 py-2 text-center border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div class="text-center">
                <label class="block text-xs text-gray-500 mb-1">4th</label>
                <input
                  type="text"
                  name="solver[position_4]"
                  value={@position_4}
                  maxlength="1"
                  class="w-full px-2 py-2 text-center border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div class="text-center">
                <label class="block text-xs text-gray-500 mb-1">5th</label>
                <input
                  type="text"
                  name="solver[position_5]"
                  value={@position_5}
                  maxlength="1"
                  class="w-full px-2 py-2 text-center border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>
            <p class="text-xs text-gray-500 mt-2">
              Enter letters you know are in specific positions
            </p>
          </div>

    <!-- Action buttons -->
          <div class="flex gap-4">
            <button
              type="submit"
              disabled={@loading}
              class="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <%= if @loading do %>
                <div class="flex items-center justify-center">
                  <svg
                    class="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      class="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      stroke-width="4"
                    >
                    </circle>
                    <path
                      class="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    >
                    </path>
                  </svg>
                  Solving...
                </div>
              <% else %>
                Find Words
              <% end %>
            </button>
            <button
              type="button"
              phx-click="clear"
              class="px-6 py-2 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
            >
              Clear
            </button>
          </div>
        </.form>

    <!-- Error display -->
        <%= if @error do %>
          <div class="mt-6 bg-red-50 border border-red-200 rounded-md p-4">
            <div class="flex">
              <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                <path
                  fill-rule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                  clip-rule="evenodd"
                />
              </svg>
              <div class="ml-3">
                <h3 class="text-sm font-medium text-red-800">Error</h3>
                <p class="text-sm text-red-700 mt-1">{@error}</p>
              </div>
            </div>
          </div>
        <% end %>

    <!-- Results -->
        <%= if length(@results) > 0 do %>
          <div class="mt-8">
            <h2 class="text-xl font-semibold text-gray-900 mb-4">
              Possible Words ({length(@results)})
            </h2>
            <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3">
              <%= for word <- @results do %>
                <div class="bg-gray-50 border border-gray-200 rounded-md p-3 text-center">
                  <span class="font-mono text-lg font-semibold text-gray-900 uppercase">
                    {word}
                  </span>
                </div>
              <% end %>
            </div>
          </div>
        <% else %>
          <%= if !@loading and (@known_letters != "" or @excluded_letters != "" or @position_1 != "" or @position_2 != "" or @position_3 != "" or @position_4 != "" or @position_5 != "") do %>
            <div class="mt-8 text-center py-8">
              <div class="text-gray-500">
                <svg
                  class="mx-auto h-12 w-12 text-gray-400 mb-4"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9.172 16.172a4 4 0 015.656 0M9 12h6m-6 0a4 4 0 010-8h6a4 4 0 010 8m-6 0v4m6-4v4"
                  />
                </svg>
                <p class="text-lg font-medium text-gray-900 mb-2">No words found</p>
                <p class="text-gray-500">Try adjusting your constraints</p>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end
