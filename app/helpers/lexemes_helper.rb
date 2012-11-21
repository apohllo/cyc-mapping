module LexemesHelper
  LEXEME_HOOK_PREFIX = "lexeme_"

  def lexeme_id(lexeme)
    LEXEME_HOOK_PREFIX + lexeme.id.to_s
  end

  def lexeme_id_from_hook(hook_id)
    hook_id[LEXEME_HOOK_PREFIX.size..-1].to_i
  end

  def inflect_adjective(gender, kase, lexeme)
    lexeme.inflect(:case => kase, :gender => gender,
                    :number => ([:pltp,:plti].include?(gender)? :pl : :sg))
  end

  def gender_options
    genders = Rlp::Lexeme::GENDERS.map do |clp_label, symbol_label|
      [Rlp::LABELS[symbol_label],symbol_label.to_s]
    end
    options_for_select(genders)
  end

  def fields_for_word_form(builder, lexeme, pos, tags, &block)
    begin
      position = Lexeme.tags_to_position(pos, tags)
      builder.fields_for(:word_forms, lexeme.word_forms[position]) do |wf|
        concat(wf.hidden_field(:position))
        yield wf
      end
    rescue
      ""
    end
  end

  def inflection_link(lexeme, name)
    link_to name, {:controller => "lexemes",
      :action => "inflection_table", :id => lexeme.id},
      :remote => true,
      :"data-update" => related_id(lexeme,"lexeme")
  end

  def stats(lexeme, main_lexeme=nil)
    if main_lexeme
      sprintf("%d %d %d %.2f|%s|%s",
              lexeme.rank[0],lexeme.rank[1],lexeme.rank[2],
              lexeme.specific_rank(:partial),
              lexeme.specific_rank(:total),
              lexeme.specific_rank(:self_conditional,main_lexeme),
              lexeme.specific_rank(:other_conditional,main_lexeme))
    else
      sprintf("%d %d %.2f %.2f",
              lexeme.rank[0],lexeme.rank[1],lexeme.rank[2],
              lexeme.specific_rank(:partial),
              lexeme.specific_rank(:total))
    end
  end

end
