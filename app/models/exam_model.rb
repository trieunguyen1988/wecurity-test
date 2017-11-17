
require "yaml/store"

class Exam

    def getQuestions(lang)
        questions = nil
        store = YAML::Store.new "./data/questions_" + lang + ".yml"
        store.transaction(true) do
            store.roots.each do |root_name|
                questions = store[root_name]
            end
        end
        return questions;
    end

    def getQuestionInfo(questions, question_id)
        item = nil
        questions.each do |question|
            if question.id.to_s == question_id                
                item = question
                break
            end
        end
        item
    end

end