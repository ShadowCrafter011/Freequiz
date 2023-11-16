import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="learn--cards"
export default class extends Controller {
    static targets = [
        "accessToken", "quizID", "doneText",
        "flipCard", "word", "translation", "learned", "learning", "unlearned", "done"
    ];
    
    connect() {
        this.access_token = $(this.accessTokenTarget).text();
        this.quiz_id = $(this.quizIDTarget).text();
        this.done_text = $(this.doneTextTarget).text();
        
        this.flip_card = $(this.flipCardTarget);
        this.word = $(this.wordTarget);
        this.translation = $(this.translationTarget);
        this.learned = $(this.learnedTarget);
        this.unlearned = $(this.unlearnedTarget);
        this.learning = $(this.learningTarget);
        this.done = $(this.doneTarget);
        
        this.available = [];
        this.current_card = null;
        
        this.quiz;
        this.quiz_data;
        this.scores_changed = [];
        
        this.setup();
    }
    
    disconnect() {
        clearInterval(this.save_interval);
    }

    flip() {
        this.flip_card.toggleClass("flipped");
    }
    
    async setup(load=true) {
        var self = this;
        
        if (load) {
            await $.get({
                url: `/api/quiz/${this.quiz_id}/data`,
                headers: {
                    "Access-token": this.access_token
                },
                success: function(data) {
                    self.quiz = data.quiz_data;
                    self.quiz_data = self.quiz.data;
                },
                error: () => Turbo.visit("/")
            });
        }
        
        this.available = [];
        this.current_card = null;

        for (var x = 0; x < this.quiz_data.length; x++) {
            if (this.quiz_data[x].score.cards == 0) this.available.push(x);
        }
        
        this.update_data();
        
        this.current_card = await this.select_card();
        this.set_card(this.current_card);
        
        var self = this;
        this.save_interval = setInterval(() => this.save_score(self), 1000);
    }
    
    save_score(self) {
        if (self.scores_changed.length == 0) return;
        
        let data = { score: {} };
        for (let translation_index of self.scores_changed) {
            let translation = self.quiz_data[translation_index];
            data.score[translation.hash] = translation.score;
        }
        
        $.ajax({
            type: "PATCH",
            url: `/api/quiz/${self.quiz.id}/score`,
            data: JSON.stringify(data),
            headers: {
                "Access-token": self.access_token
            },
            processData: false,
            contentType: "Application/json",
            error: err => console.error(err)
        });
        
        self.scores_changed = [];
    }
    
    async reset_flip() {
        if (this.flip_card.hasClass("flipped")) {
            this.flip_card.toggleClass("flipped");
            await new Promise(resolve => setTimeout(resolve, 500));
        }
    }
    
    async understood() {
        this.quiz_data[this.current_card].score.cards += 1;
        this.scores_changed.push(this.current_card);

        this.available.splice(this.available.indexOf(this.current_card), 1);
        this.quiz_data[this.current_card].score.cards = 1;

        this.current_card = await this.select_card();

        if (this.current_card == null) return;

        this.set_card(this.current_card);

        this.update_data();
    }

    async learn_again() {
        if (this.available.length == 1) {
            return this.reset_flip();
        }
    
        var card = this.current_card;
        this.available.splice(this.available.indexOf(this.current_card), 1);
    
        this.current_card = await this.select_card();
        this.set_card(this.current_card);
    
        this.available.push(card);
    }

    async set_card(index) {
        if (!index) return;
        this.word.text(this.quiz_data[index].w);
        await this.reset_flip();
        this.translation.text(this.quiz_data[index].t);
    }
    
    async select_card() {
        if (this.available.length == 0) {
            this.word.text(this.done_text);
            await this.reset_flip();
            this.translation.text(this.done_text);
            this.available = [];
            this.update_data();
    
            this.learning.toggleClass("d-none");
            this.done.toggleClass("d-none");
            return;
        }
    
        let num = Math.floor(Math.random() * this.available.length);
        return this.available[num];
    }
    
    update_data() {
        this.unlearned.text(this.available.length);
        this.learned.text(this.quiz_data.length - this.available.length);
    }
    
    async reset() {
        this.learning.toggleClass("d-none");
        this.done.toggleClass("d-none");
    
        for (let x in this.quiz_data) {
            this.quiz_data[x].score.cards = 0;
        }
    
        $.ajax({
            type: "PATCH",
            url: `/api/quiz/${this.quiz_id}/score/reset/cards`,
            headers:  {
                "Access-token": this.access_token
            }
        });
    
        this.setup(false);
    }
}
