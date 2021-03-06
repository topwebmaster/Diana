defmodule VideoChat.Encoding.FileEncoderTask do
  use Task
  import VideoChat.Encoding.Util

  def start_link(opts) do
    Task.start_link(__MODULE__, :work, [opts])
    # TODO: Remove the dumb work
    # Task.start_link(__MODULE__, :dumb_work, [opts])
  end

  def work(opts) do
    {:res, n} = Enum.at(opts, 3)
    res = get_resolution(n)
    {:path, path} = Enum.at(opts, 2)
    frame_rate = "23.98"

    {cmd, args} = VideoChat.Encoding.Util.new(path, output_dir_name())
      |> add_option(["-strict","experimental"])
      |> add_option(["-ac","2"])
      |> add_option(["-b:a","96k"])
      |> add_option(["-ar","44100"])
      |> add_option(["-c:v","libx264"])
      |> add_option(["-pix_fmt","yuv420p"])
      |> add_option(["-profile:v","main"])
      |> add_option(["-level","3.2"])
      |> add_option(["-maxrate","2M"])
      |> add_option(["-bufsize","6M"])
      |> add_option(["-crf","18"])
      |> add_option(["-g","72"])
      |> add_option(["-f","hls"])
      |> add_option(["-hls_time","9"])
      |> add_option(["-hls_list_size","0"])
      |> add_option(["-r","#{frame_rate}"])
      |> add_option(["-s","#{res}"])
      |> to_command

    System.cmd(cmd, args)
  end

  def dumb_work(opts) do
    {:res, n} = Enum.at(opts, 3)
    res = get_resolution(n)
    {:path, path} = Enum.at(opts, 2)

    System.cmd(Path.expand("bin/encode_once"),
      [path, output_dir_name(), res])
  end

  defp get_resolution(i) do
    case i do
      0 -> "240x140"
      1 -> "320x180"
      2 -> "480x270"
      3 -> "640x360"
      _ -> "1280x720"
    end
  end

  defp output_dir_name do
    dir = System.cwd
      <> "/tmp/uploads/"
      <> Base.url_encode64(:crypto.strong_rand_bytes(12))
      <> "/"
    System.cmd("mkdir", ["-p", dir])
    dir <> "/video.mp4"
  end
end
