#ifndef PLUGIN_FUNCTIONS_H_
#define PLUGIN_FUNCTIONS_H_

#include <Object.h>

typedef const bool (* plugin_init) (void);
typedef const bool (* plugin_run) (vector<Object*>& objects);
typedef const bool (* plugin_quit) (void);
typedef const void (* plugin_key_press_event) (GtkWidget* widget,
                                               GdkEventKey* event,
                                               gpointer user_data);
typedef const void (* plugin_unproject_mouse) (int x, int y);
typedef const void (* plugin_expose)(GtkWidget       *widget,
                                     GdkEventExpose  *event,
                                     gpointer        user_data);
typedef const void (* plugin_motion_notify)(GtkWidget       *widget,
                                            GdkEventMotion  *event,
                                            gpointer        user_data);


#endif
