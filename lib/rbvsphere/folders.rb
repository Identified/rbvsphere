module VSphere
  module Folders
    def root_folder
      vim.serviceInstance.content.rootFolder.childEntity.first.vmFolder
    end

    def create_folder path
      parts = path.split "/"
      curr_folder = root_folder
      parts.each do |part|
        f = curr_folder.traverse(part)
        f = curr_folder.CreateFolder(name: part) if f.nil?
        curr_folder = f
      end
    end
  end
end
