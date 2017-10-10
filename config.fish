#setup for pip w/ virtualenv - no longer required since using conda, but useful 
#potentially in the future
#set -x PIP_REQUIRE_VIRTUALENV true

function vp
    source venv/bin/activate.fish
end

function gpip
    set PIP_REQUIRE_VIRTUALENV false
    pip $argv
    set PIP_REQUIRE_VIRTUALENV true
end

#miniconda setup
set -gx PATH /Users/aliteeney/miniconda3/bin $PATH
source /Users/aliteeney/miniconda3/etc/fish/conf.d/conda.fish


#spark / aws helper functions
function chaws
	set line (cat ~/.ssh/config | grep -n 'Host aws' -A3 | grep 'HostName')
	set num (echo $line | cut -d - -f 1)
	sed -i .bak $num"s/.*/	HostName $argv/" ~/.ssh/config
end

function chspa 
	set line (cat ~/.ssh/config | grep -n 'Host spark' -A3 | grep 'HostName')
	set num (echo $line | cut -d - -f 1)
	sed -i .bak $num"s/.*/	HostName $argv/" ~/.ssh/config
end
	

function spot-req -a ami
	if count $argv > /dev/null
		set spec (sed "s/\"ImageId\":.*\$/\"ImageId\":\"$ami\",/" \
		~/.aws/p2-bare.json)
		printf "%s\n" $spec > ~/.aws/p2-bare.json
	end
	
	aws ec2 request-spot-instances --spot-price="0.25" \
	--launch-specification file://~/.aws/p2-bare.json
end

function spot-req-m -a ami
	if count $argv > /dev/null
		set spec (sed "s/\"ImageId\":.*\$/\"ImageId\":\"$ami\",/" \
		~/.aws/m4-bare.json)
		printf "%s\n" $spec > ~/.aws/m4-bare.json
	end
	
	aws ec2 request-spot-instances --spot-price="0.05" \
	--launch-specification file://~/.aws/m4-bare.json
end

function spot-req-zillow

	set ebs_id (aws ec2 describe-snapshots --filter \
	Name=tag:Name,Values=zillow --query 'Snapshots[*].SnapshotId' \
	--output=text)

	set err0 "No zillow snapshot found"
	set err2 "Multiple zillow snapshots found. Rename one in console"
	set num_ids (how_many $err0 $err2 $ebs_id)

	if [ $num_ids != 1 ]
		echo $num_ids
		return
	end 

	set spec (sed "s/\"SnapshotId\":.*\$/\"SnapshotId\":\"$ebs_id\"/" \
	~/.aws/c4spec.json)
	printf "%s\n" $spec > ~/.aws/c4spec.json

	aws ec2 request-spot-instances --spot-price="0.2" \
	--launch-specification file://~/.aws/c4spec.json
end


function spot-req-fast-ai

	set ebs_id (aws ec2 describe-snapshots --filter \
	Name=tag:Name,Values=fastai --query 'Snapshots[*].SnapshotId' \
	--output=text)

	set err0 "No fastai snapshot found"
	set err2 "Multiple fastai snapshots found. Rename one in console"
	set num_ids (how_many $err0 $err2 $ebs_id)

	if [ $num_ids != 1 ]
		echo $num_ids
		return
	end 

	set spec (sed "s/\"SnapshotId\":.*\$/\"SnapshotId\":\"$ebs_id\"/" \
	~/.aws/p2spec.json)
	printf "%s\n" $spec > ~/.aws/p2spec.json

	aws ec2 request-spot-instances --spot-price="0.3" \
	--launch-specification file://~/.aws/p2spec.json
end

function aws-poll
	set ip (aws ec2 describe-instances --filters \
	Name=instance-state-name,Values=pending,running --query \
	'Reservations[*].Instances[*].PublicDnsName' --output=text)

	set err0 "Instance not launched"
	set err2 "Multiple instance live. Check with IP with
    aws ec2 describe-instances
to check which one and then use
    chaws ip"

    	set num_ips (how_many $err0 $err2 $ip)
	if [ $num_ips = 1 ]
		echo "Instance launched, IP: $ip"
		chaws $ip
	else
		echo $num_ips
	end
end

function how_many -a  errmsg0 errmsg2 to_count
	set num_lines (echo $to_count | wc -l)
	set num_lines (echo -e $num_lines | sed -e 's/^[[:space:]]*//')
	if test -z $to_count
		echo $errmsg0
	else if [ $num_lines != 1 ]
		echo $errmsg2
	else 
		echo 1
	end
end

function aws-terminate 
	if count $argv > /dev/null
		aws ec2 terminate-instances --instance-ids $argv
	else
		set ids (aws ec2 describe-instances --filters \
		Name=instance-state-name,Values=pending,running --query \
		'Reservations[*].Instances[*].InstanceId' --output text)
		aws ec2 terminate-instances --instance-ids $ids
	end
end

function shp -a port
	if set -q $port
		set port 8888
	end
	ssh -L $port:localhost:$port aws
		
end

#quick aliases
alias g git

alias chrome "open -a \"google chrome.app\""

fish_vi_key_bindings

#autojump sourcing
[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish
