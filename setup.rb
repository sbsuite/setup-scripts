require 'securerandom'
require_relative 'utils'
require_relative 'wix'

namespace :setup do
	@deploy_dir

	desc "Performs the required steps to create a setup"
	task :all, [:src_dir, :setup_dir, :deploy_dir, :product_name, :product_version] do |task, args|
		@deploy_dir = args.deploy_dir	
		create_deploy_dir
		copy_src_files args.src_dir				
		copy_setup_files args.setup_dir					
		@product_version	= args.product_version
		@product_name	 = args.product_name	
		Rake::Task['setup:create_setup'].invoke
	end

	desc "Creates the setup: requirement: all setup dependencies should have been copied to the deploy folder"
	task :create_setup => [:prepare_files_for_setup, :run_light] 

	desc "Copy the files required to launch the setup in the deploy folder."
	task :prepare_files_for_setup do
		product_full_name = "#{@product_name} #{@product_version}"
		version_split= @product_version.split('.')
		product_release_version = "#{version_split[0]}.#{version_split[1]}"
		
		replacement = {
			'PRODUCT_ID' => Utils.uuid.to_s, 
			'PRODUCT_NAME' => @product_name, 
			'PRODUCT_VERSION' =>  @product_version, 
			'PRODUCT_FULL_NAME' => product_full_name, 
			'PRODUCT_RELEASE_VERSION' => product_release_version
		}

		Utils.replace_tokens replacement,"#{@deploy_dir}/setup.wxs"
	end

	desc "Runs the candle executable as first step of the setup process"
	task :run_candle do 
		all_wxs = []
		Dir.glob("#{@deploy_dir}/*.wxs").each{|f| all_wxs << f}
		all_options = %W[-dDeployDir=#{@deploy_dir} -ext WixUIExtension -ext WixNetFxExtension -o #{@deploy_dir}/]
		Utils.run_cmd(Wix.candle, all_wxs + all_options)
	end

	desc "Runs the light command that actually creates the msi package"
	task :run_light => [:run_candle] do 
		all_wixobj = []
		Dir.glob("#{@deploy_dir}/*.wixobj").each{|f| all_wixobj << f}
		all_options = %W[-o #{@deploy_dir}/#{@product_name}.#{@product_version}.msi -nologo -ext WixUIExtension -ext WixNetFxExtension -spdb -b #{@deploy_dir}/ -cultures:en-us]
		Utils.run_cmd(Wix.light, all_wixobj + all_options)
	end

private
	def create_deploy_dir
		FileUtils.rm_rf  @deploy_dir
		FileUtils.mkdir_p @deploy_dir  
	end

	def copy_src_files(src_dir)
		copy_to_deploy_dir "#{src_dir}/*.*"
	end

	def copy_setup_files(setup_dir)
		#copy the setup files and all fragments modules to the deploy
		copy_to_deploy_dir "#{setup_dir}/**/*.{wxs,msm,rtf,bmp}"
	end

	def copy_to_deploy_dir(source)
		Dir.glob	source do |file|
			copy file, @deploy_dir, :verbose=>false	
		end
	end
end
