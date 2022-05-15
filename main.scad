include<src/parts.scad>;

if (model == "leg") leg();

if (model == "bracket") bracket();

if (model == "bracket-inner") bracket(inner=true);

if (model == "fastener") fastener();

if (model == "tool") tool(height=10);

if (model == "table-top") table_top();

if (model == "top-plate") top_plate();
