defmodule Wordle.Solver do
  @moduledoc """
  Module for solving Wordle puzzles by filtering words based on known constraints.
  """

  def load_five_letter_words do
    words_file = get_words_file_path()

    case File.read(words_file) do
      {:ok, content} ->
        content
        |> String.split("\n", trim: true)
        |> Enum.filter(&(String.length(&1) == 5))
        |> Enum.map(&String.downcase/1)

      {:error, reason} ->
        # Log the error for debugging
        require Logger
        Logger.warning("Failed to read words file at #{words_file}: #{inspect(reason)}")
        []
    end
  end

  defp get_words_file_path do
    # Try production path first (priv directory)
    priv_path = Path.join(Application.app_dir(:wordle, "priv"), "static/words.txt")

    if File.exists?(priv_path) do
      priv_path
    else
      # Fallback to development path
      "lib/wordle/resources/words.txt"
    end
  end

  def filter_words(words, known_letters \\ "", excluded_letters \\ "", positions \\ %{}) do
    words
    |> filter_by_known_letters(known_letters)
    |> filter_by_excluded_letters(excluded_letters)
    |> filter_by_positions(positions)
  end

  defp filter_by_known_letters(words, ""), do: words

  defp filter_by_known_letters(words, known_letters) do
    required_letters =
      known_letters
      |> String.downcase()
      |> String.graphemes()
      |> Enum.uniq()

    Enum.filter(words, fn word ->
      Enum.all?(required_letters, &String.contains?(word, &1))
    end)
  end

  defp filter_by_excluded_letters(words, ""), do: words

  defp filter_by_excluded_letters(words, excluded_letters) do
    excluded_set =
      excluded_letters
      |> String.downcase()
      |> String.graphemes()
      |> MapSet.new()

    Enum.filter(words, fn word ->
      word_letters = String.graphemes(word) |> MapSet.new()
      MapSet.disjoint?(word_letters, excluded_set)
    end)
  end

  defp filter_by_positions(words, positions) when positions == %{}, do: words

  defp filter_by_positions(words, positions) do
    Enum.filter(words, fn word ->
      word_chars = String.graphemes(word)

      Enum.all?(positions, fn {pos, letter} ->
        # Convert 1-based to 0-based indexing
        index = pos - 1

        if index >= 0 and index < length(word_chars) do
          Enum.at(word_chars, index) == String.downcase(letter)
        else
          false
        end
      end)
    end)
  end

  def get_possible_words(known_letters \\ "", excluded_letters \\ "", positions \\ %{}) do
    load_five_letter_words()
    |> filter_words(known_letters, excluded_letters, positions)
    |> Enum.sort()
  end
end
