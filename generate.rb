#encoding: utf-8

require 'FileUtils'
require 'erb'
require 'kramdown'

@root_directory = '/Users/yuki/Dropbox/Sites/ThePrivateReprocess/'
@posts_directory_path = @root_directory+'_posts'
@html_directory_path = @root_directory+'diary'

@style_file_path = @root_directory+'assets/style/style.css'
@script_file_path = @root_directory+'assets/script.js'

# post = {filename: <filename>, title: <title>, body:<body>}
@posts = []

@style = ""
@script = ""
def load_assets
    `sass #{@root_directory+'assets/style/style.scss'} #{@root_directory+'assets/style/style.css'} --style compressed`
    File::open(@style_file_path){ |f|
        @style = f.read
    }
    File::open(@script_file_path){ |f|
        @script = f.read
    }
end

def make_htmls(path)
    # Open default template file
    erb = "";
    load_assets
    File::open('_layouts/default.html.erb'){ |f|
        erb = ERB.new(f.read)
    }
    FileUtils.mkdir_p(File::dirname(path))
    File::open(path, 'w+'){ |f|
        f.puts erb.result.gsub(/>(\s+?)</, "><")
    }
end

def make_monthly_html(path)
    if @posts.size > 0
        if /\/([0-9]{4})\/([0-9]{2})$/ =~ path
            year = $1
            month = $2
            html_file_name = "#{year}-#{month}.html"
            make_htmls(@html_directory_path+"/"+html_file_name)
        end

    end
    @posts = []
end

def make_yearly_html(path)
    if (/([0-9]{4})$/ =~ path) and FileTest.directory?(path)
        year_folder = $1
        make_htmls(@html_directory_path+"/"+year_folder+".html")
        @posts = []
    end
end

def extract_markdown(path)
    filename = File::basename(path)
    title = ""
    content = ""
    date = ""
    tags = []

    if filename =~ /([0-9]{4})-([0-9]{2})-([0-9]{2})_([0-9]{2})-([0-9]{2})-([0-9]{2})\.md/
        date = Time.local($1, $2, $3, $4, $5, $6)
    end

    occurrence = 0
    File::open(path) do |file|
        file.each do |line|
            if line =~ /---/
                occurrence = occurrence + 1;
                break if occurrence == 2
            end

            if line =~ /^title:\s?(.+?)$/
                title = $1
            end

            if line =~ /^tags:\s?(.+?)$/
                tags = $1.downcase.split(/^?\s*#/).reject{|a| a.size < 1}
            end
        end
        content = Kramdown::Document.new(file.read).to_html
    end
    return {filename: filename, title: title, content: content, date: date, tags: tags}
end

def traverse(path)
    if FileTest.directory?(path)
        Dir.foreach(path) do |filename|
            next if not /^[0-9]/ =~ filename

            new_path = path.sub(/\/+$/,"") + "/" + filename
            # フォルダとmdファイルが混在するケースは存在しない
            # (完璧な絶望が存在しないようにね)
            if FileTest.directory?(new_path)
                traverse(new_path)
            else
                @posts.push(extract_markdown(new_path))
            end
        end

        # どちらか片方しか実行できません！
        make_yearly_html(path)
        # make_monthly_html(path)
    end
end

traverse(@posts_directory_path)



# directory structure
# /diary
#     /2016-01.html
#     /2016-02.html
#     /2016-03.html
#     /2016-04.html
#     /...
#     /2015-01.html
#     /2015-02.html
#     /...
