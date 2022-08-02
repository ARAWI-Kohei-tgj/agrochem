module widgets.editline;

import dlangui;
class EditLineCJK: EditLine{
	this(){
		fontCJK= FontManager.instance.getFont(24, FontWeight.Normal, false, FontFamily.MonoSpace, "IPAゴシック");
	}

	override FontRef font() const @property{
		return cast(FontRef)fontCJK;
	}

private:
	FontRef fontCJK;
}
