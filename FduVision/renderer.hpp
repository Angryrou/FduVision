/**
 * Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
 * EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
 * and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
 */

#ifndef __EASYAR_SAMPLE_UTILITY_SIMPLERENDERER_H__
#define __EASYAR_SAMPLE_UTILITY_SIMPLERENDERER_H__

#include "easyar/matrix.hpp"

namespace EasyAR{
    namespace samples{
        
        class VideoRenderer
        {
        public:
            void init();
            void render(const Matrix44F& projectionMatrix, const Matrix44F& cameraview, Vec2F size);
            unsigned int texId();
        private:
            unsigned int program_box;
            int pos_coord_box;
            int pos_tex_box;
            int pos_trans_box;
            int pos_proj_box;
            unsigned int vbo_coord_box;
            unsigned int vbo_tex_box;
            unsigned int vbo_faces_box;
            unsigned int texture_id;
        };
        
    }
}
#endif
