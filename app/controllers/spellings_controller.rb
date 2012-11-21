# encoding: utf-8
class SpellingsController < ApplicationController
  layout false
  respond_to :html, :js

  def show
    @concept = Concept.find(params[:id])
    @spellings = Spelling.find_all_by_concept_id(@concept.id, :order => "position")
    @spelling = Spelling.new
    @spelling.concept = @concept
  end

  def create
    @spelling = Spelling.new(params[:spelling])
    concept = Concept.find(@spelling.concept.id)
    concept.spellings << @spelling
    @spelling.concept = concept
    @spelling.position = concept.next_spelling_position
    @spelling.status = :added
    begin
      @spelling.save!
    rescue ActiveRecord::ActiveRecordError, Spelling::Missing => e
      render :action => "raw_disambiguation"
    rescue Spelling::Ambigiuous => e
      @spellings = e.spellings
      render :action => "disambiguation"
    end
  end

  def raw_disambiguation
    @spelling = Spelling.new(params[:spelling])
    render :view => "raw_disambiguation"
  end

  def destroy
    @spelling = Spelling.find(params[:id])
    @spelling.destroy
  end

  def change_status
    spelling = Spelling.find(params[:id])
    spelling.status = params[:status]
    if spelling.status == :primary
      spelling.transaction do
        spelling.concept.spellings.each do |spell|
          if spell.status == :primary
            spell.update_attribute(:status,:validated)
          end
        end
        spelling.save
      end
    else
      spelling.save
    end
    render :layout => false, :partial => "spelling", :object => spelling
  end

end
