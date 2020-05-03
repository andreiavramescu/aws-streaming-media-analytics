.PHONY: all build package copycodeww copytemplateww syncvideos creates3 deletes3 deploy

# set bucket name prefix to be created
bucket = qos-media-code

# can set multiple AWS regions separated by space to copy the code
regions = us-west-2
version = oss-databricks-v1

# set to AWS CLI profile name to use
# profile = rodeo
profile = default

# stack deployment
deployment_region = us-west-2
deployment_file = deployment.yaml
# requied if sync of videos is done usin the make file
video_assets_bucket = aws-streaming-media-analytics-sourcecontent-us-east-1
email_address  = 'required if deployment is done using the cmd'
# set Stack Name
stack_name = mediaqos

all: image build package creates3 copycodeww copytemplateww

image:
	docker build --tag amazonlinux:qos .

build:
	docker run --rm --volume ${PWD}/lambda-functions/deploy-function:/build amazonlinux:qos /bin/bash -c "npm init -f -y; npm install adm-zip --save; npm install generate-password --save; npm install mime --save; npm install --only=prod"

	docker run --rm --volume ${PWD}/lambda-functions/recentvideoview-appsync-function:/build amazonlinux:qos /bin/bash -c "npm init -f -y; npm install es6-promise@4.1.1 --save; npm install isomorphic-fetch@2.2.1 --save; npm install --only=prod"

	docker run --rm --volume ${PWD}/lambda-functions/totalvideoview-appsync-function:/build amazonlinux:qos /bin/bash -c "npm init -f -y; npm install es6-promise@4.1.1 --save; npm install isomorphic-fetch@2.2.1 --save; npm install --only=prod"

	docker run --rm --volume ${PWD}/lambda-functions/activeuser-appsync-function:/build amazonlinux:qos /bin/bash -c "npm init -f -y; npm install es6-promise@4.1.1 --save; npm install isomorphic-fetch@2.2.1 --save; npm install --only=prod"

	mkdir -p lambda-functions/cloudfront-logs-processor-function/package
	docker run -it --rm --volume ${PWD}/lambda-functions/cloudfront-logs-processor-function:/build amazonlinux:qos /bin/bash -c "pip install --target=./package -r requirements.txt"

	mkdir -p lambda-functions/fastly-logs-processor-function/package
	docker run -it --rm --volume ${PWD}/lambda-functions/fastly-logs-processor-function:/build amazonlinux:qos /bin/bash -c "pip install --target=./package -r requirements.txt"

	docker run --rm --volume ${PWD}/lambda-functions/add-partition-function:/build amazonlinux:qos /bin/bash -c "npm init -f -y; npm install --only=prod"

	cd web/reactplayer; yarn;
	cp -av web/reactplayer/overrides/* web/reactplayer/node_modules/
	cd web/reactplayer;yarn build

package:
	mkdir -p dist && cd lambda-functions/deploy-function && zip -x \.* event.json \*.yaml -FS -q -r ../../dist/deploy-function.zip * && cd ../..
	mkdir -p dist && cd lambda-functions/cloudfront-logs-processor-function/package && zip -x \.* event.json \*.yaml -FS -q -r ../../../dist/cloudfront-logs-processor-function.zip * && cd .. && zip -g ../../dist/cloudfront-logs-processor-function.zip prep-data.py && cd ../..
	mkdir -p dist && cd lambda-functions/fastly-logs-processor-function/package && zip -x \.* event.json \*.yaml -FS -q -r ../../../dist/fastly-logs-processor-function.zip * && cd .. && zip -g ../../dist/fastly-logs-processor-function.zip prep-data.py && cd ../..
	mkdir -p dist && cd lambda-functions/recentvideoview-appsync-function && zip -FS -q -r ../../dist/recentvideoview-appsync-function.zip * && cd ../..
	mkdir -p dist && cd lambda-functions/totalvideoview-appsync-function && zip -FS -q -r ../../dist/totalvideoview-appsync-function.zip * && cd ../..
	mkdir -p dist && cd lambda-functions/activeuser-appsync-function && zip -FS -q -r ../../dist/activeuser-appsync-function.zip * && cd ../..
	mkdir -p dist && cd lambda-functions/add-partition-function && zip -FS -q -r ../../dist/add-partition-function.zip * && cd ../..
	mkdir -p dist && cd web/reactplayer/build && zip -FS -q -r ../../../dist/player-ui.zip * && cd ../../..

creates3:
	@for region in $(regions);do \
		echo $$region;	echo $(bucket); \
		aws s3 mb s3://$(bucket)-$$region --region $$region --profile $(profile); \
	done

deletes3:
	@for region in $(regions);do \
		echo $$region;	echo $(bucket); \
		aws s3 rb s3://$(bucket)-$$region --force --profile $(profile); \
	done

syncvideos:
	@for region in $(regions);do \
		aws s3 sync s3://$(video_assets_bucket)/output s3://$(bucket)-$$region/qos/sample-videos/ --acl public-read --profile $(profile);\
		mkdir -p assets/sample-videos;\
		aws s3 ls --recursive s3://$(bucket)-$$region/qos/sample-videos/ --profile $(profile) | awk '{print $$4}' > assets/sample-videos/video-manifest.txt; \
		aws s3 cp assets/sample-videos/video-manifest.txt s3://$(bucket)-$$region/qos/sample-videos/ --acl public-read --profile $(profile);\
	done


copycodeww:
	@for region in $(regions) ; do \
	  echo $$region; echo $(bucket);\
		aws s3 cp dist/deploy-function.zip s3://$(bucket)-$$region/qos/lambda-functions/ui-deployment/$(version)/ --acl public-read --profile $(profile); \
		aws s3 cp dist/player-ui.zip s3://$(bucket)-$$region/qos/lambda-functions/ui-deployment/user-interfaces/$(version)/ --acl public-read --profile $(profile); \
		aws s3 cp dist/cloudfront-logs-processor-function.zip s3://$(bucket)-$$region/qos/lambda-functions/cloudfront-logs-processor-function/$(version)/ --acl public-read --profile $(profile); \
		aws s3 cp dist/fastly-logs-processor-function.zip s3://$(bucket)-$$region/qos/lambda-functions/fastly-logs-processor-function/$(version)/ --acl public-read --profile $(profile); \
		aws s3 cp dist/recentvideoview-appsync-function.zip s3://$(bucket)-$$region/qos/lambda-functions/recentvideoview-appsync-function/$(version)/ --acl public-read --profile $(profile); \
		aws s3 cp dist/totalvideoview-appsync-function.zip s3://$(bucket)-$$region/qos/lambda-functions/totalvideoview-appsync-function/$(version)/ --acl public-read --profile $(profile); \
		aws s3 cp dist/activeuser-appsync-function.zip s3://$(bucket)-$$region/qos/lambda-functions/activeuser-appsync-function/$(version)/ --acl public-read --profile $(profile); \
		aws s3 cp dist/add-partition-function.zip s3://$(bucket)-$$region/qos/lambda-functions/add-partition-function/$(version)/ --acl public-read --profile $(profile); \
		aws s3 cp cloudformation/appsync_schema.graphql s3://$(bucket)-$$region/qos/lambda-functions/recentvideoview-appsync-function/$(version)/ --acl public-read --profile $(profile); \
		done

copytemplateww:
		@for region in $(regions);do \
		echo $$region;	echo $(bucket); \
		aws s3 cp cloudformation/$(deployment_file) s3://$(bucket)-$$region/qos/cloudformation/$(version)/ --acl public-read --profile $(profile); \
		echo https://$(bucket)-$$region.s3.amazonaws.com/qos/cloudformation/$(version)/$(deployment_file); \
		done

template:
		sed -e "s/BUCKET_NAME/${bucket}/g" -e "s/VERSION/${version}/g" cloudformation/deployment_template.yaml > cloudformation/deployment.yaml

deploy:
	aws cloudformation deploy --template-file cloudformation/$(deployment_file) --stack-name $(stack_name) --parameter-overrides Email=$(email_address) --capabilities=CAPABILITY_NAMED_IAM --profile $(profile) --region ${deployment_region}

clean:
	rm -r dist/*
	rm -r lambda-functions/activeuser-appsync-function/node_modules/*
	rm -r lambda-functions/deploy-function/node_modules/*
	rm -r lambda-functions/recentvideoview-appsync-function/node_modules/*
	rm -r lambda-functions/totalvideoview-appsync-function/node_modules/*
	rm -r web/reactplayer/build/*
	rm -r web/reactplayer/node_modules/*

cleandocker:
	docker rmi --force amazonlinux:qos
