class ArticlePicturesController < ApplicationController
  
  def new
    @article = Article.find_by_id params[:article_id]
    @new_article_picture = @article.article_pictures.new 
    @front_page_candidates = @article.front_page_candidates
    
    add_breadcrumb "Select  article", 'select_article_to_upload_for_front_page_image_path'
    set_breadcrumb_for @article, 'new_article_article_picture_path' + "(#{@article.id})", 
            "Select or Upload Front Page"
  end
  
  def create
    @article = Article.find_by_id params[:article_id]
    new_article_picture = ''
    if not params[:transloadit].nil?
      new_picture = ArticlePicture.extract_uploads( 
        params[:transloadit][:results][":original".to_sym],
        params[:transloadit][:results][:resize_index], 
        params[:transloadit][:results][:resize_front_page], 
        params[:transloadit][:results][:resize_article], 
        params, params[:transloadit][:uploads] )
    end
    
    redirect_to new_article_article_picture_url(@article) 
  end
  
  
  def execute_select_front_page
    @article = Article.find_by_id( params[:membership_provider])
    @article_picture = ArticlePicture.find_by_id( params[:membership_consumer])
    
    if not params[:membership_decision].nil?
      if params[:membership_decision].to_i == TRUE_CHECK
        @article_picture.set_as_front_page
      elsif params[:membership_decision].to_i == FALSE_CHECK
        @article_picture.remove_from_front_page
      end
      
    end
    
    respond_to do |format|
      format.html {  redirect_to root_url } 
      format.js
    end
  end
  
  
  def create_article_picture_from_assembly
    @article = Project.find_by_id( params[:article_id] )
    assembly_url = params[:assembly_url]
    # ensure_project_membership
    
    # @picture = Picture.create_from_assembly_url(assembly_url, @project)
    @article_picture = ArticlePicture.create_from_assembly_url(assembly_url, @article)
    
    respond_to do |format| 
      format.js do 
        is_completed_result = 0 
        if @article_picture.is_completed == true
          is_completed_result= 1
        end
        render :json => {'picture_id' => @article_picture.id, 'is_completed' => is_completed_result}.to_json  
      end
    end
  end
  
  
  def transloadit_status_for_article_picture
    # @picture = Picture.find_by_id( params[:picture_id])
    array_of_assembled_pic_id = ArticlePicture.assembled_pic_id_from( params[:non_completed_pic_id_list].split(",").map{|x| x.to_i })
      
    
    
    respond_to do |format| 
      format.js do 
        # is_completed_result = 0 
        # if @picture.is_completed == true
        #   is_completed_result= 1
        # end
        render :json => array_of_assembled_pic_id.to_json  
      end
    end
  end
  


  def show_article_picture_as_teaser
    # "membership_provider"=>"4", "membership_consumer"=>"1", "membership_decision"=>"1"}
    @decision = params[:membership_decision].to_i
    @article = Article.find_by_id params[:membership_provider]
    @article_picture = ArticlePicture.find_by_id params[:membership_consumer]
    
  
    if @decision == TRUE_CHECK
      @article_picture.show_as_teaser
    elsif @decision == FALSE_CHECK
      @article_picture.cancel_show_as_teaser
    end
    
    respond_to do |format|
      format.html {  redirect_to root_url }
      format.js
    end
  end
  
end

