module re.ng.diag.default_commands;

import re.core;
import re.ecs.component;
import std.range;
import std.array;
import std.algorithm;
import std.string;

static class DefaultCommands {
    alias log = Core.log;
    alias scene = Core.scene;
    alias dbg = Core.debugger;
    alias con = dbg.console;

    static void c_help(string[] args) {
        auto sb = appender!string();
        sb ~= "available commmands:\n";
        auto command_names = con.commands.keys.sort();
        foreach (command_name; command_names) {
            auto command = con.commands[command_name];
            sb ~= format("%s - %s\n", command.name, command.help);
        }
        log.info(sb.data);
    }

    static void c_entities(string[] args) {
        auto sb = appender!string();
        sb ~= "entities:\n";
        foreach (entity; scene.ecs.entities) {
            // get list of components
            auto component_types = entity.get_all_components().map!(x => x.classinfo.name);
            sb ~= format("%s: components[%d] {%s}\n", entity.name,
                    entity.components.length, component_types);
        }
        log.info(sb.data);
    }

    private static bool pick_component(string[] args, out Component comp) {
        if (args.length < 2) {
            log.err("usage: inspect <entity> <component>");
            return false;
        }
        auto nt_name = args[0];
        if (!scene.ecs.has_entity(nt_name)) {
            log.err(format("entity '%s' not found", nt_name));
            return false;
        }
        auto entity = scene.get_entity(nt_name);
        auto comp_search = args[1].toLower;
        // find matching component
        auto matches = entity.get_all_components()
            .find!(x => x.classinfo.name.toLower.indexOf(comp_search) > 0);
        if (matches.length == 0) {
            log.err(format("no matching component for '%s'", comp_search));
            return false;
        }
        comp = matches.front;
        return true;
    }

    static void c_dump(string[] args) {
        Component comp;
        if (!pick_component(args, comp)) return;
        // dump this component
        auto sb = appender!(string);
        auto comp_class = comp.getMetaType;
        log.info(format("dumping: %s", comp_class.getName));
        foreach (field; comp_class.getFields) {
            sb ~= format("%s = %s\n", field.getName, field.get(comp));
        }
        log.info(sb.data);
    }
}