include(../common.pri)
TEMPLATE = subdirs
SUBDIRS += friends/ \
	mytablet/ \
	photos/ \
	video/ \
	web/ \
	music/

OTHER_FILES += friends/*.qml \
    mytablet/*.qml \
    photos/*.qml \
    video/*.qml \
    web/*.qml \
    music/*.qml

#********* Translations *********

defineReplace(getDists) {
	retval = cd .
        subdists = $$eval($$1)
	for(subdistdir, subdists) {
		retval += && cd $${subdistdir} && make dist && cd ..
	}
	return($$retval)
}

dist.commands += $$getDists(SUBDIRS)
QMAKE_EXTRA_TARGETS += dist
#********* End Translations ******

