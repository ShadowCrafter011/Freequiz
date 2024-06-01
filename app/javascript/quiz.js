export class Quiz {
    constructor(mode, uuid, access_token, failed_to_save_target) {
        this.uuid = uuid;
        this.mode = mode;
        this.access_token = access_token;
        this.loaded = false;
        this.failed_to_save = false;
        this.failed_to_save_target = failed_to_save_target;
    }

    get translations() {
        this.require_loaded();
        return this.quiz.data;
    }

    get translations_count() {
        return this.translations.length;
    }

    get title() {
        return this.quiz.title;
    }

    get translation_language() {
        return this.quiz.to.name_translated;
    }

    get word_language() {
        return this.quiz.from.name_translated;
    }

    check(answer, correct) {
        answer = answer.toLowerCase().replaceAll(" ", "");
        correct = correct.toLowerCase().replaceAll(" ", "");
        answer = answer.replace(/\([^)]*\)?/gm, "");
        correct = correct.replace(/\([^)]*\)?/gm, "");

        if (answer == correct) return true;

        let split = correct.split(/[\/+\\+,+]/gm);
        return split.includes(answer);
    }

    selected_translation(translation) {
        if (!translation) return;
        this.current_score = translation.score_id;
    }

    translation_with(score_id) {
        this.require_loaded();
        return this.translations.find(
            (translation) => translation.score_id == score_id,
        );
    }

    increment_score(score_id = this.current_score) {
        this.require_loaded();
        this.set_score(
            score_id,
            this.translation_with(score_id).score[this.mode] + 1,
        );
    }

    decrement_score(score_id = this.current_score) {
        this.require_loaded();
        this.set_score(
            score_id,
            this.translation_with(score_id).score[this.mode] - 1,
        );
    }

    random_translation(filter_fn = (_) => true) {
        let available = this.translations.filter(filter_fn);
        let translation =
            available[Math.floor(Math.random() * available.length)];
        this.selected_translation(translation);
        return translation;
    }

    random_translation_with(score) {
        this.require_loaded();
        let available = this.translations.filter(
            (translation) => translation.score[this.mode] == score,
        );
        let index = Math.floor(Math.random() * available.length);
        this.selected_translation(available[index]);
        return available[index];
    }

    random_translation_with_lowest_score() {
        this.require_loaded();
        let grouped_by_score = this.group_by_score(this.mode);
        let entries = Object.entries(grouped_by_score);
        entries.sort((a, b) => a[0] - b[0]);
        let lowest_array = entries[0][1];
        let index = Math.floor(Math.random() * lowest_array.length);
        this.selected_translation(lowest_array[index]);
        return lowest_array[index];
    }

    group_by_score() {
        this.require_loaded();
        return Object.groupBy(
            this.translations,
            (translation) => translation.score[this.mode],
        );
    }

    async load() {
        await $.get({
            url: `/api/quiz/${this.uuid}/data`,
            headers: {
                Authorization: this.access_token,
            },
            success: (data) => {
                this.quiz = data.quiz_data;
                this.loaded = true;
            },
            error: () => {
                throw new Error("Quiz data could not be loaded");
            },
        });
        return this.quiz;
    }

    set_score(score_id, score) {
        this.require_loaded();
        this.translation_with(score_id).score[this.mode] = score;
        $.ajax({
            method: "PATCH",
            url: `/api/quiz/${this.uuid}/score/${score_id}/${this.mode}`,
            headers: {
                Authorization: this.access_token,
            },
            data: {
                score: score,
            },
            success: () => {
                this.upload_if_failed_to_save();
                this.failed_to_save = false;
                $(this.failed_to_save_target).addClass("hidden");
            },
            error: (e) => {
                this.failed_to_save = true;
                $(this.failed_to_save_target).removeClass("hidden");
                console.error(e);
            },
        });
    }

    reset_score() {
        this.require_loaded();
        this.translations.forEach((t) => (t.score[this.mode] = 0));
        $.ajax({
            type: "PATCH",
            url: `/api/quiz/${this.uuid}/score/reset/${this.mode}`,
            headers: {
                Authorization: this.access_token,
            },
            success: () => {
                this.upload_if_failed_to_save();
                this.failed_to_save = false;
                $(this.failed_to_save_target).addClass("hidden");
            },
            error: (e) => {
                this.failed_to_save = true;
                $(this.failed_to_save_target).removeClass("hidden");
                console.error(e);
            },
        });
    }

    upload_if_failed_to_save() {
        if (!this.failed_to_save) return;
        this.translations.forEach((t) =>
            this.set_score(t.score_id, t.score[this.mode]),
        );
    }

    require_loaded() {
        if (!this.loaded) throw new Error("Quiz was not yet loaded");
    }
}
