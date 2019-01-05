defmodule TwitterHistoryTest do
  use ExUnit.Case
  doctest TwitterHistory

  test "conv tweet text 1" do
    text1 = "@test  #tag1 #tag2 \n\ntextaaaa\n\n"
    assert TwitterHistory.conv_tweet_text(text1) == %{
      "tags" => "#tag1 #tag2 ",
      "text" => "textaaaa\n\n"
    }

    text2 = "#tag1 #tag2 \n\ntextaaaa\n\n"
    assert TwitterHistory.conv_tweet_text(text2) == %{
      "tags" => "#tag1 #tag2 ",
      "text" => "textaaaa\n\n"
    }

    text3 = "textaaaa\n\n"
    assert TwitterHistory.conv_tweet_text(text3) == %{
      "tags" => "",
      "text" => "textaaaa\n\n"
    }

    text4 = "@test textaaaa\n\n"
    assert TwitterHistory.conv_tweet_text(text4) == %{
      "tags" => "",
      "text" => "textaaaa\n\n"
    }

    text5 = "@test\ntextaaaa\n\naaaaa"
    assert TwitterHistory.conv_tweet_text(text5) == %{
      "tags" => "",
      "text" => "textaaaa\n\naaaaa"
    }
  end
end
