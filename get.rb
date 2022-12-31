require 'uri'
require 'net/http'
require 'm3u8'

def request_m3u8(url,dir)
    Dir.mkdir(dir) if !Dir.exist?(dir)
    puts `rm -rf ./#{dir}/*`
    File.write("./#{dir}/list.txt", "")
    File.write("./#{dir}/urls.txt", "")
    puts "[requesting] #{url}"
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    save_m3u8(res.body,url,dir) if res.is_a?(Net::HTTPSuccess)
end

def save_m3u8(text,url,dir)
    File.write("./#{dir}/video.m3u8", text)
    puts "[ok] save m3u8 to local"
    get_list(url,dir)
end

def get_list(url,dir)
    name = url.split('/').last()
    host = URI.parse(url).host
    file = File.open("./#{dir}/video.m3u8")
    list = M3u8::Playlist.read(file)
    for n in list.items do [n]
        text = "#{n}".split(/\n/)[1].strip
        fullurl = text.include?('http://')?text:url.gsub(name,text)
        fullurl = text.include?('https://')?text:url.gsub(name,text)
        filename = fullurl.split('/').last()
        File.write("./#{dir}/list.txt", "file #{filename}\n", mode: "a")
        File.write("./#{dir}/urls.txt", "#{fullurl}\n", mode: "a")
    end
    puts `echo "ffmpeg -f concat -i list.txt -c copy -bsf:a aac_adtstoasc video.mp4">./#{dir}/exec.sh`
    puts `echo "rm -rf *.ts">>./#{dir}/exec.sh`
    puts `echo "ruby ../check.rb #{dir}">./#{dir}/hook.sh`
    puts `chmod +x ./#{dir}/hook.sh`
    puts  `cd ./#{dir} && aria2c --on-download-complete "./hook.sh" -x16 -i urls.txt`
end

request_m3u8(ARGV[0],ARGV[1])
