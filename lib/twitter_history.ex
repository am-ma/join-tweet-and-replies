defmodule TwitterHistory do
  @moduledoc """
  conv tweet history
  """

  @doc """
  export tweet-tree csv
  """
  def exec_tree(filename) do
    {:ok, json} = get_json(filename)

    json
    |> conv_tweets_json
    |> join_tweets
    |> export_tree_csv
    # IO.inspect joined_tweets
  end

  defp export_tree_csv(joined_tweets) do
    now = with today <- DateTime.utc_now do
      [today.year, today.month, today.day]
      |> Enum.map(&(to_string &1))
      |> Enum.map(&String.pad_leading(&1, 2, "0"))
      |> Enum.join("")
    end

    [{_, top} | _] = joined_tweets

    header = top |> Map.keys
    body = joined_tweets
      |> Enum.map(fn {_, row} ->
        Map.values(row)
        |> Enum.map(fn row ->
          cond do
            is_list(row) -> Enum.join(row, ",")
            true -> row
          end
        end)
      end)

    file = File.open!("datas/" <> now <> ".csv", [:write, :utf8])

    [header | body]
    |> CSV.encode(delimiter: "\n")
    |> Enum.each(&IO.write(file, &1))

    :ok
  end

  # join tweets
  # tweet＋リプライを1つのmapにまとめる
  defp join_tweets(tweets) do
    # 第一要素を空の配列にしておき、それに対してたたみ込んでいく
    [[] | tweets]
    |> Enum.reduce(fn tweet, joined -> join_tweet(tweet[:parent], tweet, joined) end)
  end

  defp join_tweet("0", tweet, joined_tweets) do
    # 親tweet
    Keyword.put(joined_tweets, String.to_atom(tweet[:id]), init_joined_tweet(tweet))
  end
  defp join_tweet(parent_id, tweet, joined_tweets) do
    # リプライ
    # リプライ対象のtweetを含むtreeに追加
    {key, jtweetval} = joined_tweets
      |> Enum.find(fn {_, row} -> Enum.member?(row[:ids], parent_id) end)

    # IO.inspect tweet

    # 更新したtreeを準備
    updated_jtweet = jtweetval
      |> Map.put(:ids, [tweet[:id] | jtweetval[:ids]])
      |> Map.put(:text, jtweetval[:text] <> "\n\n" <> tweet[:text])

    # 置き換え
    Keyword.put(joined_tweets, key, updated_jtweet)
  end

  defp init_joined_tweet(tweet) do
    %{
      parent: tweet[:id],
      tags: tweet[:tags],
      text: tweet[:text],
      ids: [tweet[:id]]
    }
  end


  # convert json
  defp conv_tweets_json(json) do
    json
    |> Enum.map(fn row -> conv_tweets_json_row(row) end)
    |> Enum.sort(fn a, b ->
      if a[:parent] != b[:parent] do
        String.to_integer(a[:parent]) < String.to_integer(b[:parent])
      else
        String.to_integer(a[:id]) < String.to_integer(b[:id])
      end
    end)
  end

  defp conv_tweets_json_row(%{"id" => id, "in_reply_to_status_id_str" => parentTweet, "full_text" => fullText}) do
    ret = conv_tweet_text(fullText)
    %{id: id, parent: parentTweet, tags: ret["tags"], text: ret["text"]}
  end
  defp conv_tweets_json_row(%{"id" => id, "full_text" => fullText}) do
    conv_tweets_json_row(%{
      "id" => id,
      "in_reply_to_status_id_str" => "0",
      "full_text" => fullText
    })
  end
  defp conv_tweets_json_row(_) do
    conv_tweets_json_row(%{
      "id" => "0",
      "in_reply_to_status_id_str" => "0",
      "full_text" => ""
    })
  end

  def conv_tweet_text(text) do
    Regex.named_captures(~r/(@[^# \n]+)? *(\n)*(?<tags>#[^\n]+)?(\n)*(?<text>.*)/ius, text)
  end


  # json util
  defp get_json(filename) do
    with {:ok, body} <- File.read(filename),
          {:ok, json} <- Poison.decode(body), do: {:ok, json}
  end
end
