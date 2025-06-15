require "csv"

class FileSystem
  def read_csv(path, **options) = CSV.read(path, **options)
  def file_exists?(path) = File.exist?(path)
end
