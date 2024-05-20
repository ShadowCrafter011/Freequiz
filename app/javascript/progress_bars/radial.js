export class RadialProgressBar {
    constructor(parent, neutral_color, data = []) {
        this.parent = parent;
        this.neutral_color = neutral_color;
        this.data = data;

        this.draw();
    }

    set_data(data) {
        this.data = data;
        this.draw();
    }

    set_text(text) {
        $('[data-radial-progress-bar-target="text"]').text(text);
    }

    draw() {
        let pathes = $(this.parent).find("path");
        pathes.remove();

        let covered = 0;
        this.data.forEach((part) => {
            this.create_slice(covered, part.coverage, part.fill_color);
            covered += part.coverage;
        });

        // Fill in the neutral color
        if (covered < 1) {
            this.create_slice(covered, 1 - covered, this.neutral_color);
        }
    }

    create_slice(start, coverage, color) {
        let start_angle = start * 2 * Math.PI - Math.PI / 2;
        let sweep_angle = coverage * 2 * Math.PI;

        let start_offset = 0;

        do {
            sweep_angle -= start_offset;
            $(this.parent).prepend(
                this.createPieSlice(
                    start_angle + start_offset,
                    Math.min(sweep_angle, Math.PI),
                    color,
                ),
            );
            start_offset += Math.PI;
        } while (sweep_angle > Math.PI);
    }

    createPieSlice(start_angle, sweep_angle, color) {
        let d = "";

        const firstCircumferenceX = 5 + 5 * Math.cos(start_angle);
        const firstCircumferenceY = 5 + 5 * Math.sin(start_angle);
        const secondCircumferenceX =
            5 + 5 * Math.cos(start_angle + sweep_angle);
        const secondCircumferenceY =
            5 + 5 * Math.sin(start_angle + sweep_angle);

        // move to centre
        d += "M" + 5 + "," + 5 + " ";
        // line to first edge
        d += "L" + firstCircumferenceX + "," + firstCircumferenceY + " ";
        // arc
        // Radius X, Radius Y, X Axis Rotation, Large Arc Flag, Sweep Flag, End X, End Y
        d +=
            "A" +
            5 +
            "," +
            5 +
            " 0 0,1 " +
            secondCircumferenceX +
            "," +
            secondCircumferenceY +
            " ";
        // close path
        d += "Z";

        const arc = document.createElementNS(
            "http://www.w3.org/2000/svg",
            "path",
        );

        arc.setAttributeNS(null, "d", d);
        arc.setAttributeNS(null, "class", color);

        return arc;
    }
}
