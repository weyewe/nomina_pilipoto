class ArticlePicture < ActiveRecord::Base
  # width : 870px ( in the article display )
  
  
  
  def is_front_page_grade?
    ( not self.front_page_width.nil? ) and ( not self.front_page_height.nil? ) and 
    ( self.front_page_width == FRONT_PAGE_IMAGE_WIDTH )  and
    ( self.front_page_height == FRONT_PAGE_IMAGE_HEIGHT)
  end



  def self.extract_uploads(resize_original, resize_index , 
                    resize_front_page, resize_article, 
                    params, uploads )
    article = Article.find_by_id(params[:article_id] )
    

    new_picture = ""
    image_name = ""
    # if params[:is_original].to_i == ORIGINAL_PICTURE 
      counter = 0 

      # start looping all the transloadit data
      uploads.each do |upload|
        original_id = upload[:original_id]

        original_image_url  = ""
        index_image_url     = ""
        article_image_url = ""
        front_page_image_url = ""
        
        
        original_image_size    = ""
        index_image_size       = ""
        article_image_size = ""
        front_page_image_size = ""
        
        
        original_width = ""
        original_height ="" 
        front_page_width = ""
        front_page_height = ""


        resize_original.each do |r_index|
          if r_index[:original_id] == original_id 
            original_image_url  = r_index[:url]
            original_image_size = r_index[:size]
            original_width  = r_index[:meta][:width]
            original_height = r_index[:meta][:height]
            image_name = r_index[:name]
            break
          end
        end


        resize_index.each do |r_index|
          if r_index[:original_id] == original_id 
            index_image_url  = r_index[:url]
            index_image_size = r_index[:size]
            break
          end
        end

        #  resize article_display 
        resize_article.each do |r_index|
          if r_index[:original_id] == original_id 
             article_image_url  = r_index[:url]
             article_image_size = r_index[:size]
            break
          end
        end
        
        resize_front_page.each do |r_index|
          if r_index[:original_id] == original_id 
             front_page_image_url  = r_index[:url]
             front_page_image_size = r_index[:size]
             front_page_width =  r_index[:meta][:width]
             front_page_height = r_index[:meta][:height]
            break
          end
        end

        new_picture = ArticlePicture.create(
           :name                          =>  image_name                                ,
           :article_id                    =>  article.id                                ,
           :original_image_url            =>  original_image_url                        ,
           :article_image_url             =>  article_image_url                         ,
           :front_page_image_url          =>  front_page_image_url                      ,
           :index_image_url               =>  index_image_url                           ,
           :original_image_size           =>  original_image_size                       ,
           :article_image_size            =>  article_image_size                        ,
           :front_page_image_size         =>  front_page_image_size                     ,
           :index_image_size              =>  index_image_size                          ,
           :article_picture_type          =>  ARTICLE_PICTURE_TYPE[:pure_article_upload],
           :width                         =>  original_width                            ,
           :height                        =>  original_height                           ,
           :front_page_width              =>  front_page_width                          ,
           :front_page_height             =>  front_page_height          
        )

        counter =  counter + 1 

     
      end #end of uploads loop
      
      
    # end
    
    return new_picture
  end
  
  
  def is_selected_for_front_page?
    self.is_selected_front_page == true 
  end
  
  
  def set_as_front_page
    self.is_selected_front_page = true 
    self.save
  end
  
  def remove_from_front_page
    self.is_selected_front_page  = false
    self.save
  end
  
  def resize_original_for_article
    # the transloadit shite
    
    if Rails.env.production?
      transloadit_read = YAML::load( File.open( Rails.root.to_s + "/config/transloadit.yml") )
      s3_bucket = S3_BUCKET_BLOG_PROD
    elsif Rails.env.development?
      transloadit_read = YAML::load( File.open( Rails.root.to_s + "/config/transloadit_dev.yml") )
      s3_bucket = S3_BUCKET_BLOG_DEV
    end
    
    
    
    
    transloadit = Transloadit.new(
      :key    => transloadit_read['auth']['key'], #'a919ae5378334f20b8db4f7610cdd1a7',
      :secret => transloadit_read['auth']['secret'], #'7dff49aab9dc91cb62a0fd34bf9e8c2d6eb3b207'
    )
    import = transloadit.step 'imported_image', '/http/import', 
      :url => self.original_image_url
      
    resize_front_page = transloadit.step 'resize_front_page', '/image/resize', 
      :use => "imported_image",
      :width => FRONT_PAGE_WIDTH,
      :zoom => false 
      
    resize_article = transloadit.step 'resize_article', '/image/resize', 
      :use => "imported_image",
      :width => ARTICLE_WIDTH,
      :zoom => false 
      
    store_resize_front_page  = transloadit.step 'store_resize_front_page', '/s3/store',
      :key    => 'AKIAIIMPWOLZCXR3TNLA',
      :secret => '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',
      :bucket => s3_bucket, 
      :use => 'resize_front_page'
      
    store_resize_article  = transloadit.step 'store_resize_article', '/s3/store',
      :key    => 'AKIAIIMPWOLZCXR3TNLA',
      :secret => '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',
      :bucket => s3_bucket, 
      :use => 'resize_article'
      
    assembly = transloadit.assembly(
      :steps => [ import,  resize_front_page, resize_article,
                            store_resize_front_page, store_resize_article ]
    )
    
    response = assembly.submit!

    while not response.completed? do
      puts "In the cycle"
      sleep 1
      response.reload!
    end
    
    transloadit_params = ActiveSupport::HashWithIndifferentAccess.new(
          ActiveSupport::JSON.decode response
        )
    
    
    self.front_page_image_url = response[:results][:resize_front_page].first[:url]
    self.front_page_image_size = response[:results][:resize_front_page].first[:size]

    self.article_image_url = response[:results][:resize_article].first[:url]
    self.article_image_size = response[:results][:resize_article].first[:size]
     #    
     # 
     # self.front_page_image_url = response["results"]["resize_front_page"].first["url"]
     # self.front_page_image_size = response["results"]["resize_front_page"].first["size"]
     # 
     # self.article_image_url = response["results"]["resize_article"].first["url"]
     # self.article_image_size = response["results"]["resize_article"].first["size"]
    self.is_completed = true 
    self.save
  end
  
  
  def ArticlePicture.create_from_assembly_url(assembly_url, article)
    pic = ArticlePicture.create(:assembly_url => assembly_url, :is_completed => false , :article_id => article.id)
    
    pic.delay.extract_from_assembly_url
    return pic
  end
  
  def extract_from_assembly_url
    content = open(self.assembly_url).read
    # json = JSON.parse(content)
    
    
    
    transloadit_params = ActiveSupport::HashWithIndifferentAccess.new(
          ActiveSupport::JSON.decode content
        )
        
    while transloadit_params[:ok] != "ASSEMBLY_COMPLETED"
      sleep 2
      puts "in the loop"
      content = open(self.assembly_url).read
      transloadit_params = ActiveSupport::HashWithIndifferentAccess.new(
            ActiveSupport::JSON.decode content
          )
    end
    
    # t.string  :original_image_url
    # t.string  :article_image_url
    # t.string  :front_page_image_url  # not generated yet. can be pinged 
    # t.string :index_image_url
    # 
    #  t.integer  :original_image_size
    #   t.integer  :article_image_size
    #   t.integer :front_page_image_size
    #   t.integer :index_image_size
    # 

    puts "the transloadit_params: #{transloadit_params}"
    self.original_image_url  = transloadit_params[:results][':original'].first[:url]
    self.index_image_url     = transloadit_params[:results][:resize_index].first[:url]   
    self.front_page_image_url   = transloadit_params[:results][:resize_front_page].first[:url]     
    self.article_image_url   = transloadit_params[:results][:resize_article].first[:url]   
    
    self.original_image_size = transloadit_params[:results][':original'].first[:size]
    self.index_image_size    = transloadit_params[:results][:resize_index].first[:size]         
    self.front_page_image_size = transloadit_params[:results][:resize_front_page].first[:size]                
    self.article_image_size  = transloadit_params[:results][:resize_article].first[:size]  
    
      
    self.name                = transloadit_params[:results][':original'].first[:name]
    self.width               = transloadit_params[:results][':original'].first[:meta][:width]
    self.height              = transloadit_params[:results][':original'].first[:meta][:height] 
    self.is_completed        = true
    self.save
      
  end
  
  def ArticlePicture.assembled_pic_id_from( pic_id_list ) 
    ArticlePicture.find(:all, :conditions => {
      :id => pic_id_list, 
      :is_completed => true 
    }).map{|x| x.id }
  end
  
  def show_as_teaser
    self.is_displayed_as_teaser = true 
    self.save
  end
  
  
  def cancel_show_as_teaser
    self.is_displayed_as_teaser = false  
    self.save
  end
    
  
  
  
end
