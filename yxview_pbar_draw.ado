
program yxview_pbar_draw
	.style.area.setgdifull

	local dropx = "`.bar_drop_to.stylename'" == "x"
	if `dropx' {
		local min = `.`.plotregion'.yscale.curmin'
		local max = `.`.plotregion'.yscale.curmax'
	}
	else {
		local min = `.`.plotregion'.xscale.curmin'
		local max = `.`.plotregion'.xscale.curmax'
	}
	if `.base' < . {
		local base `.base'
	}
	else {
		if `min' <= 0 & `max' >= 0{
			local base 0
		} 
		else{                       
			local base = cond(`max' < 0 , `max' , `min')
		}
	}
	
	if(`.drop_base.istrue'){
		.drawn_base = `base'
	}
	else{
		.drawn_base = (.)
	}
	
	.serset.set			// just in case
	draw_pbar `dropx' `base' `.pattern'	// draw
end

program _draw_prect
	args x0 y0 x1 y1 pattern
	gdi shadepattern = `pattern'
	gdi shadechange
	gdi moveto `x0' `y0'
	gdi polybegin
	gdi lineto `x0' `y1'
	gdi lineto `x1' `y1'
	gdi lineto `x1' `y0'
	gdi lineto `x0' `y0'
	gdi polyend
end

program _fr_draw_prect
	args style x0 y0 x1 y1 preset pattern

	if 0`.`style'.linestyle.patterned_line' {
		.`style'.setgdifull

		tempname linesty
		.`linesty' = .linestyle.new, style(background)
		.`linesty'.remake_as_copy
		.`linesty'.color.remake_as_copy
		.`linesty'.color.opacity = 0
		.`linesty'.setgdifull
		_draw_prect `x0' `y0' `x1' `y1' `pattern'

		.`style'.linestyle.setgdifull
		_draw_prect `x0' `y0' `x1' `y1' `pattern'
	}
	else {
		if "`preset'" == "" {
			.`style'.setgdifull
		}
		_draw_prect `x0' `y0' `x1' `y1' `pattern'
	}
end

program draw_pbar
	args dropx base pattern
	draw_p`.bartype.stylename' `dropx' `base' `pattern'	// draw type
end


program draw_pfixed
	args dropx base pattern

	if 0`.cvar' {
		draw_pfixed_color `dropx' `base' `pattern'
		exit
	}
	
	local d = `.bar_size' / 2
	if `dropx' {
		forvalues j = 1/`:serset N' {
		    if ("`.obs_styles[`j'].isa'" != "") {
			local style "obs_styles[`j'].area"
		    }
		    else {
			local style "style.area"
		    }

		    local x = serset(`.xvar', `j')
		    _fr_draw_prect `style' `=`x'-`d'' `base' `=`x'+`d'' `=serset(`.yvar', `j')' "" `pattern'
		}
	}
	else {
		forvalues j = 1/`:serset N' {
		    if ("`.obs_styles[`j'].isa'" != "") {
			local style "obs_styles[`j'].area"
		    }
		    else {
			local style "style.area"
		    }
		    local y = serset(`.xvar', `j')
		    _fr_draw_prect `style' `base' `=`y'-`d'' `=serset(`.yvar', `j')' `=`y'+`d'' "" `pattern'
		}
	}
end

program draw_pfixed_color
	args dropx base pattern
	
	local d = `.bar_size' / 2

	.colorstyle.reset
	.serset.set
	.reset_colorserset	
	.color_serset.set	
	
	if `dropx' {
		forvalues j = 1/`:serset N' {		
		    if ("`.obs_styles[`j'].isa'" != "") {
			local style "obs_styles[`j'].area"
		    }
		    else {
			local style "colorstyle.area"
		    }

		    local x = serset(`.xvar', `j')
		    local level = serset(`.levelvar', `j')
		    _draw_a_rect_color `style' `level' `=`x'-`d'' `base' `=`x'+`d'' `=serset(`.yvar', `j')' `pattern'
		}
	}
	else {
		forvalues j = 1/`:serset N' {
		    if ("`.obs_styles[`j'].isa'" != "") {
			local style "obs_styles[`j'].area"
		    }
		    else {
			local style "colorstyle.area"
		    }
		    local y = serset(`.xvar', `j')
		    local level = serset(`.levelvar', `j')
		    _draw_a_rect_color `style' `level' `base' `=`y'-`d'' `=serset(`.yvar', `j')' `=`y'+`d'' `pattern'
		}
	}
	.serset.set
end

program _draw_a_rect_color
	args style level x0 y0 x1 y1 pattern

	if 0`.style.area.linestyle.patterned_line' {		
		if 0`level'  > 0 & 0`level' <= 0`.colorstyle.cstyles.arrnels' {
			.colorstyle.cstyles[`level'].color.setgdifull, line
			.colorstyle.cstyles[`level'].color.setgdifull, shade
		}
		else {
			if "`.colorstyle.usercolorformissing'" == "yes" {
				.colorstyle.colorformissing.setgdifull, line
				.colorstyle.colorformissing.setgdifull, shade					
			}
			else {
				tempname c
				.`c'  = .color.new, rgb(128 128 128)
				.`c'.setgdifull, line
				.`c'.setgdifull, shade				
			}			
		}
		
		tempname linesty
		.`linesty' = .linestyle.new, style(background)
		.`linesty'.remake_as_copy
		.`linesty'.color.remake_as_copy
		.`linesty'.color.opacity = 0
		.`linesty'.setgdifull
		_draw_prect `x0' `y0' `x1' `y1' `pattern'

	}
	else {	
		if 0`level'  > 0 & 0`level' <= `.colorstyle.cstyles.arrnels' {
			.colorstyle.cstyles[`level'].color.setgdifull, line
			.colorstyle.cstyles[`level'].color.setgdifull, shade
		}
		else {
			if "`.colorstyle.usercolorformissing'" == "yes" {
				.colorstyle.colorformissing.setgdifull, line
				.colorstyle.colorformissing.setgdifull, shade					
			}
			else {
				tempname c
				.`c'  = .color.new, rgb(128 128 128)
				.`c'.setgdifull, line
				.`c'.setgdifull, shade				
			}
		}
	}
	_draw_prect `x0' `y0' `x1' `y1' `pattern'
	
	if 0`.colorfillonly' {
		.style.area.setgdifull
		gdi moveto  `x0'  `y0'
		gdi lineto  `x1'  `y0' 
		gdi lineto  `x1'  `y1'
		gdi lineto  `x0'  `y1'
		gdi lineto  `x0'  `y0'		
	}
	else {
		.style.remake_as_copy
		.style.area.remake_as_copy
		.style.area.linestyle.remake_as_copy
		.style.area.linestyle.color.remake_as_copy
		if 0`level'  > 0 & 0`level' <= `.colorstyle.cstyles.arrnels' {
			.style.area.linestyle.color.setrgba `.colorstyle.cstyles[`level'].color.rgbasetting' 
		}
		else {
			if "`.colorstyle.usercolorformissing'" == "yes" {
				.style.area.linestyle.color.setrgba `.colorstyle.colorformissing.rgbasetting' 		
			}
			else {
				.style.area.linestyle.color.setrgba 128 128 128 100 					
			}
		}
		.style.area.setgdifull
		
		gdi moveto  `x0'  `y0'
		gdi lineto  `x1'  `y0' 
		gdi lineto  `x1'  `y1'
		gdi lineto  `x0'  `y1'
		gdi lineto  `x0'  `y0'				
	}
end