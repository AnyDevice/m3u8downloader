files_count = Dir.glob("*.ts").count
puts files_count
tasks_count = File.readlines('list.txt').count
puts tasks_count
puts files_count == tasks_count
if files_count == tasks_count
   puts `bash exec.sh`
   puts `rm -rf *.ts`
end
