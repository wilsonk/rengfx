module re.ng.diag.inspector;

import re.core;
import re.ecs;
import re.math;
import re.gfx;
import std.conv;
import std.array;
import std.algorithm;
import std.typecons;
import std.string;
import re.util.interop;
import witchcraft;
static import raylib;
static import raygui;

/// real-time object inspector
class Inspector {
    /// panel width
    enum width = 400;
    /// whether the inspector is open
    public bool open = false;
    private Vector2 _panel_scroll;
    private InspectedComponent[] _components;
    private Entity entity;
    private enum btn_close = ['x', '\0'];

    private class InspectedComponent {
        public Component obj;
        public Class obj_class;
        public string[string] fields;

        this(Component obj) {
            this.obj = obj;
            this.obj_class = obj.getMetaType;
        }

        private void update_fields() {
            foreach (field; obj_class.getFields) {
                string field_name = field.getName;
                string field_value = to!string(field.get(obj));
                this.fields[field_name] = field_value;
            }
        }
    }

    this() {
        reset();
    }

    private void reset() {
        _components = [];
        entity = null;
    }

    public void update() {
        // update all inspected components
        foreach (comp; _components) {
            comp.update_fields();
        }
    }

    public void render() {
        alias pad = Core.debugger.screen_padding;

        // this is the (clipped) scrollable panel bounds
        auto panel_bounds = Rectangle(pad, pad, width, Core.window.height - pad * 2);
        // draw indicator of panel bounds
        // raylib.DrawRectangleRec(panel_bounds, Colors.GRAY);

        // - layout vars
        enum field_height = 16; // for each field
        enum field_padding = 2;
        enum field_label_width = 120;
        enum field_value_width = 240;
        enum header_height = field_height; // for each component
        enum header_padding = 4;
        enum header_line_margin = 4;
        enum title_height = field_height; // for each entity
        enum title_padding = 8;

        // calculate panel bounds
        // this is going to calculate the space required for each component
        int[] component_section_heights;

        foreach (comp; _components) {
            component_section_heights ~= (header_padding + header_padding) // header
             + ((field_height + field_padding) // field and padding
                     * ((cast(int) comp.fields.length) + 1)); // number of fields
        }
        // total height
        auto panel_bounds_height = pad + component_section_heights.sum() + (
                title_height + title_padding);

        // bounds of the entire panel
        auto panel_content_bounds = Rectangle(0, 0, width - pad, panel_bounds_height);

        auto view = raygui.GuiScrollPanel(panel_bounds, panel_content_bounds, &_panel_scroll);

        // start scissor
        raylib.BeginScissorMode(cast(int) view.x, cast(int) view.y,
                cast(int) view.width, cast(int) view.height);
        // end scissor on scope exit
        scope (exit)
            raylib.EndScissorMode();

        // close button
        enum btn_close_sz = 12;
        if (raygui.GuiButton(Rectangle(panel_bounds.x + panel_content_bounds.width - pad,
                panel_bounds.y + pad, btn_close_sz, btn_close_sz), cast(char*) btn_close)) {
            close();
            return; // when closed, cancel this render
        }

        // the corner of the inside of the panel (pre-padded)
        auto panel_corner = Vector2(panel_bounds.x + pad, panel_bounds.y + pad);

        // entity title
        auto entity_title = format("Entity %s", entity.name);
        raygui.GuiLabel(Rectangle(panel_corner.x, panel_corner.y,
                field_label_width, title_height), entity_title.c_str());
        // title underline
        raylib.DrawRectangleLinesEx(Rectangle(panel_corner.x,
                panel_corner.y + title_height, panel_bounds.width - pad * 2, 4), 1, Colors.GRAY);

        // - now draw each component section
        auto panel_y_offset = (title_height + title_padding); // the offset from the y start of the panel (this is based on component index)
        foreach (i, comp; _components) {
            auto field_names = comp.fields.keys.sort();
            auto field_index = 0;

            // corner for the start of this section
            auto section_corner = Vector2(panel_corner.x, panel_corner.y + panel_y_offset);
            // header
            raygui.GuiLabel(Rectangle(section_corner.x, section_corner.y,
                    field_label_width, header_height), comp.obj_class.getName.c_str());
            // header underline
            raylib.DrawRectangleLinesEx(Rectangle(section_corner.x + header_line_margin,
                    section_corner.y + header_height, panel_bounds.width - header_line_margin * 2,
                    1), 1, Colors.GRAY);
            // list of fields
            foreach (field_name; field_names) {
                auto field_val = comp.fields[field_name];
                // calculate field corner
                auto corner = Vector2(section_corner.x,
                        section_corner.y + (header_height + header_padding) + field_index * (
                            field_padding + field_height));
                raygui.GuiLabel(Rectangle(corner.x, corner.y,
                        field_label_width, field_height), field_name.c_str());
                raygui.GuiTextBox(Rectangle(corner.x + field_label_width, corner.y,
                        field_value_width, field_height), field_val.c_str(),
                        field_value_width, false);
                field_index++;
            }
            panel_y_offset += component_section_heights[i]; // go to the bottom of this section
        }
        // raygui.GuiGrid(Rectangle(panel_bounds.x + _panel_scroll.x, panel_bounds.y + _panel_scroll.y,
        //         panel_content_bounds.width, panel_content_bounds.height), 16, 4);
    }

    /// attach the inspector to an object
    public void inspect(Entity nt) {
        assert(_components.length == 0, "only one inspector may be open at a time");
        open = true;
        this.entity = nt;
        // add components
        _components ~= nt.get_all_components.map!(x => new InspectedComponent(x)).array;
    }

    /// close the inspector
    public void close() {
        assert(open, "inspector is already closed");
        open = false;
        reset();
    }
}
