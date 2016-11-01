require 'securerandom'
require_relative 'utils'
require_relative 'wix'

namespace :setup do
	desc "Performs the required steps to create a setup"
	task :create, [:src_dir, :setup_dir, :deploy_dir, :product_name, :product_version] do |task, args|
		@deploy_dir = args.deploy_dir	
		@product_version	= args.product_version
		@product_name	 = args.product_name	

		create_deploy_dir
		copy_src_files args.src_dir				
		copy_setup_files args.setup_dir					
		Rake::Task['setup:create_setup'].invoke
	end

	desc "Creates the setup: requirement: all setup dependencies should have been copied to the deploy folder"
	task :create_setup => [:set_variables_for_setup, :run_light] 

	desc "Copy the files required to launch the setup in the deploy folder."
	task :set_variables_for_setup do
		@variables = {}
		@variables[:ProductId] = Utils.uuid.to_s
		@variables[:DeployDir] = @deploy_dir
		@variables[:ProductName] =@product_name
		@variables[:ProductVersion] = @product_version
		@variables[:ProductFullName] = "#{@product_name} #{@product_version}"
		version_split= @product_version.split('.')
		@variables[:ProductReleaseVersion] = "#{version_split[0]}.#{version_split[1]}"		
	end

	desc "Runs the candle executable as first step of the setup process"
	task :run_candle do 
		all_wxs = Dir.glob("#{@deploy_dir}/*.wxs")
		all_variables = @variables.each.collect do |k, v|
			"-d#{k}=#{v}"
		end
		all_options = %W[-ext WixUIExtension -ext WixNetFxExtension -o #{@deploy_dir}/]
		Utils.run_cmd(Wix.candle, all_wxs + all_variables + all_options)
	end

	desc "Runs the light command that actually creates the msi package"
	task :run_light => [:run_candle] do 
		all_wixobj = Dir.glob("#{@deploy_dir}/*.wixobj")
		all_options = %W[-o #{@deploy_dir}/#{@product_name}.#{@product_version}.msi -nologo -ext WixUIExtension -ext WixNetFxExtension -spdb -b #{@deploy_dir}/ -cultures:en-us]
		Utils.run_cmd(Wix.light, all_wixobj + all_options)
	end

private
	def create_deploy_dir
		FileUtils.rm_rf  @deploy_dir
		FileUtils.mkdir_p @deploy_dir  
	end

	def copy_src_files(src_dir)
		copy_to_deploy_dir File.join(src_dir, '*.*')
	end

	def copy_setup_files(setup_dir)
		#copy the setup files and all fragments modules to the deploy
		copy_to_deploy_dir File.join(setup_dir,'**/*.{wxs,msm,rtf,bmp}')
	end

	def copy_to_deploy_dir(source)
		Dir.glob	source do |file|
			copy file, @deploy_dir, :verbose=>false	
		end
	end
end
