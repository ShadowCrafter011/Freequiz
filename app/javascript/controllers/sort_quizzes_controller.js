import { Controller } from "@hotwired/stimulus";
import jaro_winkler from "jaro-winkler";

// Connects to data-controller="sort-quizzes"
export default class extends Controller {
    static targets = ["titleQuery", "order", "quizzes"];

    connect() {
        this.title_query = $(this.titleQueryTarget);
        this.order = $(this.orderTarget);
        this.quizzes = $(this.quizzesTarget);

        this.title_buckets = {};
        this.all_bucket = [];

        for (let quiz of this.quizzes.children()) {
            let q = $(quiz);
            this.all_bucket.push(q);
            let title = q.data("title");
            if (title in this.title_buckets) {
                this.title_buckets[title].push(q);
            } else {
                this.title_buckets[title] = [q];
            }
        }
    }

    sort() {
        let sorted = [];

        let order_val = this.order.val();
        let data_attr, order;
        switch (order_val) {
            case "newest":
            case "oldest":
                data_attr = "created";
                order = order_val == "newest" ? -1 : 1;
                break;
            case "most_translations":
            case "least_translations":
                data_attr = "translations";
                order = order_val == "most_translations" ? -1 : 1;
                break;
            default:
                return;
        }

        if (this.title_query.val().length > 0) {
            let ordered_titles = this.sort_titles();
            for (let bucket_data of Object.entries(this.title_buckets)) {
                let sorted_bucket = this.sort_array(
                    bucket_data[1],
                    data_attr,
                    order,
                );
                this.title_buckets[bucket_data[0]] = sorted_bucket;
            }

            for (let title of ordered_titles) {
                sorted = sorted.concat(this.title_buckets[title]);
            }
        } else {
            sorted = this.sort_array(this.all_bucket, data_attr, order);
        }

        this.quizzes.children().remove();
        this.quizzes.append(sorted);
    }

    sort_array(array, data_attr, order) {
        if (array.length < 2) return array;
        let array_with_attr = array.map((t) => [t, t.data(data_attr)]);
        array_with_attr.sort((a, b) => order * (a[1] - b[1]));
        return array_with_attr.map((t) => t[0]);
    }

    sort_titles() {
        let titles = Object.entries(this.title_buckets).map((data) => data[0]);
        let query = this.title_query.val();
        let title_with_dist = [];
        for (let title of titles) {
            title_with_dist.push([title, jaro_winkler(query, title)]);
        }
        title_with_dist.sort((a, b) => b[1] - a[1]);
        return title_with_dist.map((t) => t[0]);
    }
}
